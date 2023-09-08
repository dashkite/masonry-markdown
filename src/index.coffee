import marked from "marked"

# TODO support presets with masonry-export?

markdown = ({ input }) -> marked input

export { markdown }
