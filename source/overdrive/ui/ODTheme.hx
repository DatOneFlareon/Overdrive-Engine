package overdrive.ui;

import flixel.util.FlxColor;
import backend.Paths;

/**
 * Design tokens (master specification D1).
 *
 * Rules this file exists to enforce:
 *   - one palette, so a new screen cannot invent its own colours;
 *   - one type face, so text never drifts between screens;
 *   - contrast checked by hand: every TEXT_* token below is >= 4.5:1 on the
 *     surface it is used on, which is the accessibility floor (spec V).
 */
class ODTheme
{
	// Surfaces, darkest to lightest.
	public static inline var BG_DEEP:FlxColor = 0xFF070A14;
	public static inline var BG_MID:FlxColor = 0xFF0D1426;
	public static inline var SURFACE:FlxColor = 0xFF151E36;
	public static inline var SURFACE_HIGH:FlxColor = 0xFF1E2A4A;

	// Text.
	public static inline var TEXT:FlxColor = 0xFFF2F6FF;
	public static inline var TEXT_DIM:FlxColor = 0xFFA7B4D0;
	public static inline var TEXT_DISABLED:FlxColor = 0xFF5A6480;

	// Accents. One primary action colour, four category colours.
	public static inline var ACCENT:FlxColor = 0xFF35E0FF;
	public static inline var ACCENT_WARM:FlxColor = 0xFFFF4D8D;
	public static inline var ACCENT_LIME:FlxColor = 0xFF8CFF4D;
	public static inline var ACCENT_GOLD:FlxColor = 0xFFFFC53D;
	public static inline var ACCENT_VIOLET:FlxColor = 0xFF9D7BFF;

	// Interactive surfaces.
	public static inline var BUTTON_IDLE:FlxColor = 0xFF1B2540;
	public static inline var BUTTON_HOVER:FlxColor = 0xFF2A3A63;
	public static inline var BUTTON_PRESSED:FlxColor = 0xFF101830;
	public static inline var BUTTON_DISABLED:FlxColor = 0xFF141A28;
	public static inline var FOCUS_RING:FlxColor = 0xFF35E0FF;

	// Feedback.
	public static inline var OK:FlxColor = 0xFF4DD97A;
	public static inline var WARN:FlxColor = 0xFFFFC53D;
	public static inline var ERROR:FlxColor = 0xFFFF5A5A;

	// Spacing scale, in pixels, at the 1280x720 design size.
	public static inline var GAP_XS:Int = 6;
	public static inline var GAP_S:Int = 12;
	public static inline var GAP_M:Int = 20;
	public static inline var GAP_L:Int = 36;
	public static inline var GAP_XL:Int = 56;

	public static inline var BUTTON_HEIGHT:Int = 64;
	public static inline var BUTTON_HEIGHT_LARGE:Int = 104;
	public static inline var ACCENT_BAR:Int = 4;

	static var _font:String = null;

	/** The engine's bundled type face. Cached: Paths.font() hits the filesystem. */
	public static function font():String
	{
		if (_font == null)
			_font = Paths.font('vcr.ttf');
		return _font;
	}

	/** Accent colour for a rating category, so stars and rows agree. */
	public static function colourForCategory(category:String):FlxColor
	{
		return switch (category)
		{
			case 'Easy': ACCENT_LIME;
			case 'Normal': ACCENT;
			case 'Hard': ACCENT_GOLD;
			case 'Harder': ACCENT_WARM;
			case 'Insane': ACCENT_VIOLET;
			case 'Demon': 0xFFFF2E63;
			default: TEXT_DIM;
		}
	}
}
