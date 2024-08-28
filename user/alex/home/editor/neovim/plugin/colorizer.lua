require('colorizer').setup(
	{
		-- '*',
		css = {
			names = true,
			css = true,
		},
	},
	{
		RGB = true,
		RRGGBB = true,
		RRGGBBAA = true,

		rgb_fn = true,
		hsl_fn = true,

		names = false,
		css = false,
		css_fn = true,

		mode = 'background',
	}
)
