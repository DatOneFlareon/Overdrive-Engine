package overdrive;

/**
 * The global star system (master specification G1).
 *
 * A rating has two independent parts:
 *   - the difficulty category, which decides the star band;
 *   - optionally, the Demon sub-difficulty, which is metadata only.
 *
 * Every Demon sub-difficulty is a flat 10 stars. That is deliberate: the star
 * number is the global measure, the sub-difficulty is the community label.
 */
typedef ODStarRange =
{
	var min:Int;
	var max:Int;
}

enum abstract ODDifficulty(String) to String
{
	var EASY = 'Easy';
	var NORMAL = 'Normal';
	var HARD = 'Hard';
	var HARDER = 'Harder';
	var INSANE = 'Insane';
	var DEMON = 'Demon';
}

enum abstract ODDemonTier(String) to String
{
	var NONE = '';
	var EASY_DEMON = 'Easy Demon';
	var MEDIUM_DEMON = 'Medium Demon';
	var HARD_DEMON = 'Hard Demon';
	var INSANE_DEMON = 'Insane Demon';
	var EXTREME_DEMON = 'Extreme Demon';
}

class ODRating
{
	/** Star band per category, exactly as the specification defines it. */
	public static var RANGES(default, null):Map<String, ODStarRange> = [
		'Easy' => {min: 2, max: 2},
		'Normal' => {min: 3, max: 3},
		'Hard' => {min: 4, max: 5},
		'Harder' => {min: 6, max: 7},
		'Insane' => {min: 8, max: 9},
		'Demon' => {min: 10, max: 10}
	];

	/** All Demon sub-difficulties. Evergreen order, easiest first. */
	public static var DEMON_TIERS(default, null):Array<String> = [
		'Easy Demon',
		'Medium Demon',
		'Hard Demon',
		'Insane Demon',
		'Extreme Demon'
	];

	public static function categories():Array<String>
	{
		return ['Easy', 'Normal', 'Hard', 'Harder', 'Insane', 'Demon'];
	}

	public static function isKnownCategory(category:String):Bool
	{
		return category != null && RANGES.exists(category);
	}

	public static function isDemon(category:String):Bool
	{
		return category == 'Demon';
	}

	public static function isKnownTier(tier:String):Bool
	{
		return tier != null && DEMON_TIERS.contains(tier);
	}

	public static function rangeFor(category:String):Null<ODStarRange>
	{
		return RANGES.get(category);
	}

	/**
	 * Maps an inherited Psych difficulty name onto a rating category.
	 * Returns null for anything Overdrive has no official band for (Erect,
	 * Nightmare, custom week difficulties). Null means "unrated", never a guess.
	 */
	public static function categoryForDifficulty(difficultyName:String):Null<String>
	{
		if (difficultyName == null) return null;
		var key:String = difficultyName.toLowerCase().trim();
		return switch (key)
		{
			case 'easy': 'Easy';
			case 'normal': 'Normal';
			case 'hard': 'Hard';
			case 'harder': 'Harder';
			case 'insane': 'Insane';
			case 'demon': 'Demon';
			default: null;
		}
	}

	/**
	 * The star value that appears everywhere in the UI. Demons are always 10,
	 * whatever their sub-difficulty is.
	 */
	public static function globalStars(category:String, rated:Int):Int
	{
		if (isDemon(category))
			return 10;
		var range:Null<ODStarRange> = rangeFor(category);
		if (range == null)
			return 0;
		return Std.int(Math.max(range.min, Math.min(range.max, rated)));
	}

	/**
	 * Display form of a category's band. Ranges stay ranges: there is no
	 * per-song official rating yet, so "4-5" is the truthful answer.
	 */
	public static function bandLabel(category:String):String
	{
		var range:Null<ODStarRange> = rangeFor(category);
		if (range == null) return 'Unrated';
		if (range.min == range.max) return '${range.min} stars';
		return '${range.min}-${range.max} stars';
	}

	/**
	 * Why a proposed official rating is impossible, or null when it is valid.
	 * Callers show this text; they never repair the value silently.
	 */
	public static function validate(category:String, rated:Int, tier:String):String
	{
		if (!isKnownCategory(category))
			return 'Unknown difficulty category.';

		if (isDemon(category))
		{
			if (rated != 10) return 'A Demon is always 10 stars in the global system.';
			if (!isKnownTier(tier)) return 'A Demon needs a sub-difficulty (Easy Demon .. Extreme Demon).';
			return null;
		}

		if (tier != null && tier.length > 0)
			return 'Only Demons carry a sub-difficulty.';

		var range:ODStarRange = rangeFor(category);
		if (rated < range.min || rated > range.max)
			return '${category} is ${range.min} stars' + (range.min == range.max ? '.' : ' to ${range.max} stars.');

		return null;
	}

	/** Human label, e.g. "Demon · Extreme Demon" or "Hard · 5 stars". */
	public static function describe(category:String, rated:Int, tier:String):String
	{
		var stars:Int = globalStars(category, rated);
		if (isDemon(category) && isKnownTier(tier))
			return '${category} · ${tier}';
		return '${category} · ${stars} star' + (stars == 1 ? '' : 's');
	}

	/** Star glyph for compact rows; the number is authoritative, this is decoration. */
	public static function starGlyphs(category:String, rated:Int):String
	{
		var n:Int = globalStars(category, rated);
		return n <= 0 ? '·' : '${n}★';
	}
}
