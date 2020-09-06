std = "lua51+minetest"
unused_args = false
allow_defined_top = true
max_line_length = 999
max_comment_line_length = 999

stds.minetest = {
	read_globals = {
		"minetest",
		"vector",
		"VoxelManip",
		"VoxelArea",
		"PseudoRandom",
		"ItemStack",
		"default",
		table = {
			fields = {
				"copy",
			},
		},
		"dump",
	}
}

read_globals = {
	"biome_lib",
	"stairsplus",
	"stairs",
	"doors",
}
