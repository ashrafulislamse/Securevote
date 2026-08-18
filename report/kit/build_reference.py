"""Build a pandoc reference document for SmartCura FYP reports (A4).

Pandoc applies the "Table" table style and the "Compact" paragraph style
to generated tables. This script modifies those STYLE DEFINITIONS (not
sample cells) so every pandoc-generated table inherits correct borders,
fonts, and header formatting.

Page size: A4 (210 mm x 297 mm) with 25 mm margins all around.

Run from anywhere; the output is always saved next to this script as
reference.docx:
    python build_reference.py
"""
import os
from docx import Document
from docx.shared import Pt, Mm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

_script_dir = os.path.dirname(os.path.abspath(__file__))
_output_path = os.path.join(_script_dir, 'reference.docx')

doc = Document()
styles = doc.styles

# ── A4 page setup ─────────────────────────────────────────────
# Set every section to A4 with 25 mm margins.
for section in doc.sections:
    section.page_width = Mm(210)
    section.page_height = Mm(297)
    section.top_margin = Mm(25)
    section.bottom_margin = Mm(25)
    section.left_margin = Mm(25)
    section.right_margin = Mm(25)


def _ensure_child(parent, tag):
    """Find or create a child element with the given qualified tag name."""
    el = parent.find(qn(tag))
    if el is None:
        el = OxmlElement(tag)
        parent.append(el)
    return el


def _set_border(border_el, val='single', sz='4', color='BFBFBF'):
    border_el.set(qn('w:val'), val)
    border_el.set(qn('w:sz'), sz)
    border_el.set(qn('w:color'), color)
    border_el.set(qn('w:space'), '0')


def _apply_font_to_style(style, name='Times New Roman', size_pt=12, bold=False, italic=False, color=(0, 0, 0)):
    """Set font properties on a style's rPr, including East Asian slots."""
    style.font.name = name
    style.font.size = Pt(size_pt)
    style.font.bold = bold
    style.font.italic = italic
    style.font.color.rgb = RGBColor(*color)
    rPr = style.element.get_or_add_rPr()
    rFonts = _ensure_child(rPr, 'w:rFonts')
    rFonts.set(qn('w:ascii'), name)
    rFonts.set(qn('w:hAnsi'), name)
    rFonts.set(qn('w:cs'), name)
    rFonts.set(qn('w:eastAsia'), name)


# ── Body / Normal ──────────────────────────────────────────────
normal = styles['Normal']
_apply_font_to_style(normal, size_pt=12)
normal.paragraph_format.line_spacing_rule = WD_LINE_SPACING.ONE_POINT_FIVE
normal.paragraph_format.space_after = Pt(6)
normal.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY

# ── Title ─────────────────────────────────────────────────────
title = styles['Title']
_apply_font_to_style(title, size_pt=18, bold=True)
title.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.CENTER
title.paragraph_format.space_after = Pt(18)

# ── Headings 1-3 ──────────────────────────────────────────────
for level, (size, before, after) in {1: (16, 18, 6), 2: (14, 12, 6), 3: (12, 10, 4)}.items():
    h = styles[f'Heading {level}']
    _apply_font_to_style(h, size_pt=size, bold=True)
    h.paragraph_format.space_before = Pt(before)
    h.paragraph_format.space_after = Pt(after)
    h.paragraph_format.line_spacing_rule = WD_LINE_SPACING.ONE_POINT_FIVE
    h.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.LEFT
    h.paragraph_format.keep_with_next = True

# ── Compact (used by pandoc for table cell text) ──────────────
try:
    compact = styles['Compact']
except KeyError:
    compact = styles.add_style('Compact', 1)  # paragraph style
_apply_font_to_style(compact, size_pt=12)
compact.paragraph_format.line_spacing_rule = WD_LINE_SPACING.SINGLE
compact.paragraph_format.space_after = Pt(0)
compact.paragraph_format.space_before = Pt(0)

# ── Block Quote (used by pandoc for figure captions) ─────────
try:
    bq = styles['Block Quote']
    _apply_font_to_style(bq, size_pt=11, italic=True, color=(60, 60, 60))
    bq.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.CENTER
    bq.paragraph_format.space_before = Pt(4)
    bq.paragraph_format.space_after = Pt(10)
except KeyError:
    pass

# ── List styles ──────────────────────────────────────────────
for list_name in ('List Bullet', 'List Number'):
    try:
        ls = styles[list_name]
        _apply_font_to_style(ls, size_pt=12)
        ls.paragraph_format.line_spacing_rule = WD_LINE_SPACING.ONE_POINT_FIVE
        ls.paragraph_format.space_after = Pt(3)
    except KeyError:
        pass

# ── Table style ──────────────────────────────────────────────
# This is the key fix: modify the STYLE DEFINITION, not sample cells.
# Pandoc applies <w:tblStyle w:val="Table"/> to every table it generates,
# so the borders defined here propagate to all tables.
try:
    table_style = styles['Table']
except KeyError:
    from docx.enum.style import WD_STYLE_TYPE
    table_style = styles.add_style('Table', WD_STYLE_TYPE.TABLE)

tbl_el = table_style.element

# 1) Table-level properties: borders + cell padding
tblPr = _ensure_child(tbl_el, 'w:tblPr')

# Remove any existing tblBorders
existing = tblPr.find(qn('w:tblBorders'))
if existing is not None:
    tblPr.remove(existing)

# Add tblBorders: thin grey single-line on all six edges
tbl_borders = OxmlElement('w:tblBorders')
for edge in ('top', 'left', 'bottom', 'right', 'insideH', 'insideV'):
    b = OxmlElement(f'w:{edge}')
    _set_border(b, sz='4', color='BFBFBF')
    tbl_borders.append(b)
tblPr.append(tbl_borders)

# Cell default margins (padding)
tblCellMar = _ensure_child(tblPr, 'w:tblCellMar')
for edge, width in [('top', '60'), ('bottom', '60'), ('left', '108'), ('right', '108')]:
    m = tblCellMar.find(qn(f'w:{edge}'))
    if m is None:
        m = OxmlElement(f'w:{edge}')
        tblCellMar.append(m)
    m.set(qn('w:w'), width)
    m.set(qn('w:type'), 'dxa')

# 2) Conditional formatting: header row (firstRow) — bold + light grey fill
# Remove any existing firstRow conditional
for existing in tbl_el.findall(qn('w:tblStylePr')):
    if existing.get(qn('w:type')) == 'firstRow':
        tbl_el.remove(existing)

first_row = OxmlElement('w:tblStylePr')
first_row.set(qn('w:type'), 'firstRow')

# Run properties: bold
rPr = OxmlElement('w:rPr')
b_el = OxmlElement('w:b')
rPr.append(b_el)
first_row.append(rPr)

# Cell properties: light grey shading
tcPr = OxmlElement('w:tcPr')
shd = OxmlElement('w:shd')
shd.set(qn('w:val'), 'clear')
shd.set(qn('w:color'), 'auto')
shd.set(qn('w:fill'), 'F2F2F2')
tcPr.append(shd)
first_row.append(tcPr)

tbl_el.append(first_row)

# 3) Set the table's default paragraph font (so "Compact" inside cells
# inherits TNR 12 even if pandoc overrides the paragraph style)
rPr_default = _ensure_child(tbl_el, 'w:rPr')
rFonts = _ensure_child(rPr_default, 'w:rFonts')
rFonts.set(qn('w:ascii'), 'Times New Roman')
rFonts.set(qn('w:hAnsi'), 'Times New Roman')
rFonts.set(qn('w:cs'), 'Times New Roman')
sz_el = _ensure_child(rPr_default, 'w:sz')
sz_el.set(qn('w:val'), '24')  # 12pt = 24 half-points
color_el = _ensure_child(rPr_default, 'w:color')
color_el.set(qn('w:val'), '000000')

doc.save(_output_path)
print(f'reference.docx written to {_output_path}')
print('Page size: A4 (210 x 297 mm), margins 25 mm')
print('Table style: thin grey borders, TNR 12, bold header row with grey fill, cell padding')
