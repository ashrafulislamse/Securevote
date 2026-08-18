// Lightweight in-memory D1 mock for endpoint tests.
//
// We only need the subset of the D1 surface the routes use:
// prepare(sql).bind(...).first()/all()/run()/raw(). This mock records
// calls and returns canned results keyed by normalized SQL so tests can
// assert on behaviour without spinning up a real database.

export type Row = Record<string, unknown>;

export interface RecordedCall {
  sql: string;
  params: unknown[];
}

function normalize(sql: string): string {
  return sql.replace(/\s+/g, " ").trim();
}

function contains(needle: string, haystack: string): boolean {
  return normalize(haystack).includes(normalize(needle));
}

export class MockD1 {
  private calls: RecordedCall[] = [];
  private firstStubs: { match: string; row: Row | null }[] = [];
  private allStubs: { match: string; rows: Row[] }[] = [];
  private runStubs: { match: string; changes: number }[] = [];
  private defaultChanges = 1;

  // -- stubbing API ---------------------------------------------------------

  /** Stub .first() for any prepared SQL containing `match` (substring, normalized). */
  stubFirst(match: string, row: Row | null): this {
    this.firstStubs.push({ match: normalize(match), row });
    return this;
  }

  /** Stub .all() for any prepared SQL containing `match` (substring, normalized). */
  stubAll(match: string, rows: Row[]): this {
    this.allStubs.push({ match: normalize(match), rows });
    return this;
  }

  /** Stub .run() for any prepared SQL containing `match` (substring, normalized). */
  stubRun(match: string, changes = 1): this {
    this.runStubs.push({ match: normalize(match), changes });
    return this;
  }

  /** Set the default .run() change count (used when no stub matches). */
  setDefaultChanges(changes: number): this {
    this.defaultChanges = changes;
    return this;
  }

  // -- inspection API ------------------------------------------------------

  recordedCalls(): RecordedCall[] {
    return [...this.calls];
  }

  /** True if any recorded SQL contains `match`. */
  calledWith(match: string): boolean {
    return this.calls.some((c) => contains(match, c.sql));
  }

  reset(): void {
    this.calls = [];
    this.firstStubs = [];
    this.allStubs = [];
    this.runStubs = [];
    this.defaultChanges = 1;
  }

  // -- D1 surface ----------------------------------------------------------

  prepare(sql: string): D1PreparedStatement {
    const norm = normalize(sql);
    const record = (params: unknown[]) => {
      this.calls.push({ sql: norm, params });
    };

    const lookup = (): D1PreparedStatement => {
      // LIFO: later stubs override earlier ones, so test-specific stubs
      // take precedence over stubs set in beforeEach.
      const findFirst = (): Row | null => {
        for (let i = this.firstStubs.length - 1; i >= 0; i--) {
          if (norm.includes(this.firstStubs[i]!.match)) return this.firstStubs[i]!.row;
        }
        return null;
      };
      const findAll = (): Row[] => {
        for (let i = this.allStubs.length - 1; i >= 0; i--) {
          if (norm.includes(this.allStubs[i]!.match)) return this.allStubs[i]!.rows;
        }
        return [];
      };
      const findRun = (): number => {
        for (let i = this.runStubs.length - 1; i >= 0; i--) {
          if (norm.includes(this.runStubs[i]!.match)) return this.runStubs[i]!.changes;
        }
        return this.defaultChanges;
      };

      return {
        bind: (...params: unknown[]): D1PreparedStatement => {
          record(params);
          return lookup();
        },
        first: async <T>(): Promise<T | null> => {
          record([]);
          return findFirst() as T | null;
        },
        all: async <T>(): Promise<{ results: T[]; success: true; meta: D1Result["meta"] }> => {
          record([]);
          return { results: findAll() as T[], success: true, meta: {} as D1Result["meta"] };
        },
        run: async <T = unknown>(): Promise<D1Result<T>> => {
          record([]);
          return { success: true, meta: { changes: findRun() } } as D1Result<T>;
        },
        raw: async <T = unknown>(): Promise<T[]> => {
          record([]);
          return findAll() as unknown as T[];
        },
      } as unknown as D1PreparedStatement;
    };

    return lookup();
  }

  async batch<T = unknown>(statements: D1PreparedStatement[]): Promise<D1Result<T>[]> {
    const results: D1Result<T>[] = [];
    for (const s of statements) {
      results.push(await s.run<T>());
    }
    return results;
  }

  async exec(_query: string): Promise<D1Result> {
    return { success: true, meta: { changes: 0 } } as D1Result;
  }
}

// Re-export the D1Database type alias so consumers can type variables
// without importing workers-types directly.
export type { D1Database, D1PreparedStatement, D1Result } from "@cloudflare/workers-types";

/** Parse a Hono Response body as typed JSON (res.json() returns `unknown`). */
export async function jsonBody<T>(res: Response): Promise<T> {
  return (await res.json()) as T;
}

