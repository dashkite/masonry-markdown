import { marked } from "marked"


markdown = ({ input }) -> marked.parse input

export { markdown }
