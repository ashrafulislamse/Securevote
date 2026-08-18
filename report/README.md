# SecureVote FYP Report Section

This is the dedicated report section for the SecureVote Final Year Project.
It contains chapter sources (Markdown), conversion scripts, diagrams, and
final submitted documents for both Project 1 and Project 2.

## Folder Structure

```
report/
├── README.md                              ← this file
├── kit/                                   ← shared conversion toolkit
│   ├── build_reference.py                 ← builds pandoc reference.docx (A4)
│   ├── postprocess.py                     ← post-processes REPORT.docx
│   ├── build.py                           ← full pipeline: pandoc + postprocess
│   ├── reference.docx                     ← generated pandoc style template
│   └── diagrams/                          ← shared diagram assets
│
├── project-1/                             ← Semester 1 report (Chapters 1–3)
│   ├── source/                            ← Markdown chapter sources
│   │   ├── chapter-1-introduction.md
│   │   ├── chapter-2-literature-review.md
│   │   └── chapter-3-methodology.md
│   └── diagrams/                          ← chapter diagrams (PNG exports)
│
└── project-2/                             ← Semester 2 report (Chapters 4–6)
    ├── source/                            ← Markdown chapter sources
    │   ├── chapter-4.md
    │   ├── chapter-5.md
    │   └── chapter-6.md
    └── diagrams/                          ← chapter diagrams (PNG exports)
```

## Word Document Pipeline

The conversion follows the same approach used for university assignments:
Markdown → pandoc → DOCX → post-process → (manual PDF export from Word).

### Prerequisites

Install these once on your machine:

| Tool | How to check | Install |
|---|---|---|
| **pandoc 3.x** | `pandoc --version` | <https://pandoc.org/installing.html> |
| **Python 3.10+** | `python --version` | <https://www.python.org/downloads/> |
| **python-docx** | `pip show python-docx` | `pip install python-docx` |

### Page Setup

All documents are **A4** (210 × 297 mm) with **25 mm margins**, **Times New
Roman 12 pt**, **1.5 line spacing**, and **justified body text**.

### Step-by-Step

**1. Edit the Markdown source**

Write or edit chapter files in `project-1/source/` or `project-2/source/`.
Each chapter is a standalone Markdown file.

**2. Build the reference template (first time only)**

```bash
cd report/kit
python build_reference.py
```

This creates `reference.docx` — the pandoc style template that controls fonts,
table borders, heading spacing, and page size. Rebuild it only if you change
`build_reference.py`.

**3. Convert Markdown → DOCX**

Convert each chapter individually. Examples for Project 2:

```bash
cd report/kit
python build.py ../project-2/source/chapter-4.md
python build.py ../project-2/source/chapter-5.md
python build.py ../project-2/source/chapter-6.md
```

Option B — manual pandoc + post-process:

```bash
cd report/kit
pandoc ../project-1/source/chapter-3-methodology.md \
  -o REPORT.docx \
  --reference-doc=reference.docx \
  --resource-path=../project-1/source
python postprocess.py
```

**4. Manual steps in Word**

Open `REPORT.docx` in Microsoft Word and add:

- Cover page
- Table of contents
- Page numbers
- AI use disclosure (required by City University Malaysia)

**5. Export PDF from Word**

Use **File → Save As → PDF** in Word.
Do **not** use pandoc for PDF — it ignores `reference.docx` styles.

### Important Notes

- **Close Word before regenerating** `REPORT.docx`. Pandoc fails with
  permission denied if Word has the file open.
- **Don't run `postprocess.py` twice** without regenerating `REPORT.docx`
  first (some operations are not idempotent).
- **Image alt-text**: use `![](path)` with empty alt text so pandoc generates
  only the explicit `**Figure X.**` caption, not a duplicate.
- **Diagrams**: written in [Mermaid](https://mermaid.js.org/) syntax as `.mmd`
  files in each project's `diagrams/` folder. Render them to PNG using the
  [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli):
  ```bash
  npm install -g @mermaid-js/mermaid-cli
  mmdc -i diagrams/context-diagram.mmd -o diagrams/context-diagram.png -w 1400 -b white
  ```
  Or paste the `.mmd` content into [mermaid.live](https://mermaid.live/)
  and export as PNG.

## Academic Writing Rules

These follow City University Malaysia FYP requirements:

- **Font**: Times New Roman 12 pt
- **Line spacing**: 1.5
- **Citation style**: APA 7
- **Minimum references**: 3 per chapter (check brief for exact number)
- **AI use without citation = disqualification**
- **References**: hanging indent 0.5 inch, alphabetical order, italic book titles

### Banned Words (AI-detection avoidance)

Never use these in any report:

- **Phrases**: Furthermore, Moreover, Overall, In conclusion
- **Vocabulary**: leverages, leveraged, leveraging, utilizes, utilized,
  utilizing, utilised, utilising, facilitates, facilitate, facilitating,
  ameliorates, ameliorate, ameliorating, delve, navigate, landscape, realm,
  tapestry

## Diagrams

Mermaid source files (`.mmd`) are included in each project's `diagrams/`
folder. Render them to PNG before building the DOCX.

### Project 1 (chapter-3-methodology.md)

| Diagram | Source | Output | Description |
|---|---|---|---|
| Agile Process | `diagrams/agile-process.mmd` | `diagrams/agile-process.png` | Sprint cycle diagram |
| Context Diagram | `diagrams/context-diagram.mmd` | `diagrams/context-diagram.png` | DFD Level 0 |
| Level 1 DFD | `diagrams/dfd-level1.mmd` | `diagrams/dfd-level1.png` | Detailed data flow |

### Project 2 (chapter-4.md)

| Diagram | Source | Output | Description |
|---|---|---|---|
| System Architecture | `diagrams/system-architecture.mmd` | `diagrams/system-architecture.png` | Three-tier architecture |
| ER Diagram | `diagrams/er-diagram.mmd` | `diagrams/er-diagram.png` | Entity relationships |

### Project 2 (chapter-5.md)

Screenshots from the running app and web portal (capture manually). Chapter 6 uses no diagrams.

| Screenshot | File |
|---|---|
| Login screen | `diagrams/screenshot-login.png` |
| OTP verification | `diagrams/screenshot-otp.png` |
| KYC upload | `diagrams/screenshot-kyc-upload.png` |
| KYC pending | `diagrams/screenshot-kyc-pending.png` |
| Home screen | `diagrams/screenshot-home.png` |
| Ballot screen | `diagrams/screenshot-ballot.png` |
| Vote success | `diagrams/screenshot-vote-success.png` |
| Admin dashboard | `diagrams/screenshot-admin-dashboard.png` |
| Admin KYC review | `diagrams/screenshot-admin-kyc.png` |
| Admin audit log | `diagrams/screenshot-admin-audit.png` |
| Public verifier | `diagrams/screenshot-verifier.png` |
