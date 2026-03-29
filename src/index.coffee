import { unified } from "unified"
import remarkParse from "remark-parse"
import remarkGFM from "remark-gfm"
import remarkMath from "remark-math"
import remarkSupersub from "remark-supersub"
import remarkDirective from "remark-directive"
import remarkRehype from "remark-rehype"
import rehypeKatex from "rehype-katex"
import rehypeSlug from "rehype-slug"
import rehypeAutolinkHeadings from "rehype-autolink-headings"
import { createHighlighter } from "shiki"
import rehypeShikiFromHighlighter from "@shikijs/rehype/core"
import rehypeStringify from "rehype-stringify"
import { visit } from "unist-util-visit"

import rehypeSanitize from "rehype-sanitize"
import rehypeRaw from "rehype-raw"

import xxhash from "xxhash-wasm"

admonitions = ->
  (tree) ->
    visit tree, (node) ->
      if node.type in ["containerDirective", "leafDirective", "textDirective"]
        data = node.data or (node.data = {})
        tagName = if node.type is "textDirective" then "span" else "div"
        data.hName = tagName
        data.hProperties = 
          class: "admonition admonition-#{node.name}"


highlighter = null

cache = {}
markdown = ->

  highlighter ?= await createHighlighter
    themes: [
      "github-light"
      "github-dark"
      "github-light-high-contrast"
      "github-dark-high-contrast" 
    ]
    langs: [ "javascript", "coffeescript", "css", "html", "yaml" ]

  parser = unified()
    .use remarkParse
    .use remarkGFM
    .use remarkMath
    .use remarkSupersub
    .use remarkDirective
    .use admonitions
    .use remarkRehype, allowDangerousHtml: true
    .use rehypeRaw
    .use rehypeSanitize
    .use rehypeKatex
    .use rehypeSlug
    .use rehypeAutolinkHeadings,
      behavior: "append"
      properties:
        ariaHidden: true
        tabIndex: -1
      content: [
        {
          type: "element"
          tagName: "i"
          properties: { className: [ "ri-link-m" ], ariaHidden: "true" }
        }
        {
          type: "element"
          tagName: "span"
          properties: { className: [ "hidden" ] }
          children: [{ type: "text", value: "Permalink" }]
        }
      ]
    # Pass the pre-warmed instance to the rehype plugin
    .use rehypeShikiFromHighlighter, highlighter,
      themes:
        light: "github-light-high-contrast"
        dark: "github-dark-high-contrast"        
      defaultColor: "light-dark()"

      # theme: "github-dark"
    .use rehypeStringify

  Hash = await xxhash()
  ({ input }) ->
    cache[ Hash.h32 input ] ?= do ->
      { value } = parser.processSync input
      value

export default markdown
export { markdown }


