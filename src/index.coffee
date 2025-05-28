import { marked } from "marked"


markdown = ({ input }) -> 
  marked.parse input, gfm: true

export { markdown }
