---
task: shard-doc
agent: pm
inputs:
  - source_path (required, string, path to the document to shard)
  - output_path (optional, string, destination folder, default: derived from source)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - sharded_files (array, list of created file paths)
  - index_file (string, path to the generated index file)
  - section_count (number, total sections extracted)
---

# Document Sharding

## Purpose
Split a large document into multiple smaller documents based on level 2 sections (`##` headings). Creates a folder structure with an index file linking to all shards, while maintaining complete content integrity including code blocks, diagrams, and markdown formatting.

## Prerequisites
- Source document exists and is readable
- Target directory is writable
- For automatic mode: `@kayvan/markdown-tree-parser` npm package (optional, enables faster sharding)

## Steps

### 1. Check for Automatic Sharding Tool

Check if `@kayvan/markdown-tree-parser` is available:

```bash
md-tree explode {source_path} {output_path}
```

- If the command succeeds, report success and stop
- If the tool is not installed, inform the user they can install it with `npm install -g @kayvan/markdown-tree-parser` for better performance
- Proceed with manual sharding if the tool is unavailable

### 2. Read and Parse Source Document

Read the entire document content and identify all level 2 sections (`##` headings).

**Critical parsing rules:**
- A `##` inside a fenced code block (between triple backticks) is NOT a section header
- Properly handle nested markdown elements
- Preserve complete fenced code blocks including closing backticks
- Preserve Mermaid diagrams, tables, lists, and all markdown formatting

### 3. Extract Sections

For each level 2 section:
- Extract the heading and ALL content until the next level 2 section
- Include all subsections, code blocks, diagrams, lists, and tables
- Handle edge cases with `##` symbols inside code blocks

### 4. Generate Filenames

**Filename generation algorithm:**

1. Extract heading text (remove `##` prefix and trim)
2. Translate Portuguese terms to English if document language is Portuguese (e.g., "Visao do Produto" -> "product-vision")
3. Normalize to lowercase-dash-case
4. Remove accents and special characters
5. Clean up consecutive dashes

**Common translations:**
- visao -> vision, produto -> product, requisitos -> requirements
- arquitetura -> architecture, testes -> tests, seguranca -> security
- dados -> data, desempenho -> performance, riscos -> risks

**Special cases:**
- Numbers in headings: Remove numbering prefixes
- Parentheses/brackets: Convert to dashes
- Acronyms (API, RLS, CI/CD): Keep as-is
- Mixed language headings: Keep English terms unchanged

### 5. Adjust Heading Levels

In each sharded file:
- The level 2 heading (`##`) becomes level 1 (`#`)
- All subsection levels decrease by 1 (`###` -> `##`, `####` -> `###`, etc.)

### 6. Create Index File

Create an `index.md` in the output folder containing:
- The original level 1 heading and any content before the first level 2 section
- A linked list of all sharded files

```markdown
# Original Document Title

[Original introduction content]

## Sections

- [Section Name 1](./section-name-1.md)
- [Section Name 2](./section-name-2.md)
```

### 7. Preserve Special Content

Ensure complete preservation of:
- Fenced code blocks (with language tags)
- Mermaid diagrams
- Markdown tables (proper formatting)
- Nested lists (indentation preserved)
- Inline code (backtick content)
- Links and references
- Template markup (`{{placeholders}}`)

### 8. Validation

After sharding:
- Verify all sections were extracted
- Check that no content was lost
- Confirm heading levels were properly adjusted
- Validate all files were created successfully

### 9. Report Results

```text
Document sharded successfully:
- Source: {source_path}
- Destination: {output_folder}/
- Files created: {count}
- Sections:
  - section-name-1.md: "Section Title 1"
  - section-name-2.md: "Section Title 2"
```

## Error Handling
- **Source file not found:** Exit with clear error, suggest checking the path
- **Output directory not writable:** Exit with permission error, suggest fix
- **No level 2 sections found:** Warn user, suggest the document may not need sharding
- **Code block parsing error:** Log warning, attempt best-effort extraction
- **Duplicate section names:** Append numeric suffix to filenames
- **Automatic tool fails:** Fall back to manual sharding process
