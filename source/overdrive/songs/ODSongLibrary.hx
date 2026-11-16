package overdrive.songs;

import backend.WeekData;
import backend.Difficulty;
import backend.Paths;
import states.StoryMenuState;

/**
 * One playable song, as the menus need it.
 *
 * Deliberately thin: no chart data, no audio references, no character objects.
 * Loading those for every song at once is exactly what the performance section
 * forbids. The chart is read only when the player actually starts the song.
 */
typedef ODSongMeta =
{
	var name:String;            // display name, as written in the week file
	var folder:String;          // Paths.formatToSongPath(name), the chart folder
	var week:String;            // owning week; needed to set the mod directory
	var character:String;       // week file's character/icon name
	var colour:Int;
	var difficulties:Array<String>;
}

class ODSongLibrary
{
	public static var songs(default, null):Array<ODSongMeta> = [];
	static var loaded:Bool = false;

	/** Reads week metadata once. force=true re-reads after a mod or week change. */
	public static function ensureLoaded(force:Bool = false):Void
	{
		if (loaded && !force) return;

		songs = [];
		WeekData.reloadWeekFiles(false);

		for (weekName in WeekData.weeksList)
		{
			var week:WeekData = WeekData.weeksLoaded.get(weekName);
			if (week == null || weekIsLocked(week)) continue;

			var diffs:Array<String> = difficultiesOf(week);

			for (entry in week.songs)
			{
				if (entry == null || entry.length < 2) continue;

				var songName:String = Std.string(entry[0]);
				if (songName == null || songName.length == 0) continue;

				var colour:Int = 0xFF9271FD;
				var colours:Dynamic = entry.length > 2 ? entry[2] : null;
				if (colours != null && colours.length >= 3)
					colour = FlxColor.fromRGB(colours[0], colours[1], colours[2]);

				songs.push({
					name: songName,
					folder: Paths.formatToSongPath(songName),
					week: weekName,
					character: Std.string(entry[1]),
					colour: colour,
					difficulties: diffs
				});
			}
		}

		loaded = true;
	}

	/** Same rule as FreeplayState: a locked week hides its songs. */
	static function weekIsLocked(week:WeekData):Bool
	{
		if (week.startUnlocked) return false;
		if (week.weekBefore == null || week.weekBefore.length == 0) return false;
		if (!StoryMenuState.weekCompleted.exists(week.weekBefore)) return true;
		return !StoryMenuState.weekCompleted.get(week.weekBefore);
	}

	/** A week may declare its own difficulty list; otherwise the default applies. */
	public static function difficultiesOf(week:WeekData):Array<String>
	{
		var raw:String = week == null ? null : week.difficulties;
		if (raw == null || raw.trim().length == 0) return Difficulty.defaultList.copy();

		var out:Array<String> = [];
		for (part in raw.split(','))
		{
			var trimmed:String = part.trim();
			if (trimmed.length > 0) out.push(trimmed);
		}
		return out.length > 0 ? out : Difficulty.defaultList.copy();
	}

	/** Case-insensitive title search. An empty query returns everything. */
	public static function search(query:String):Array<ODSongMeta>
	{
		var q:String = query == null ? '' : query.toLowerCase().trim();
		if (q.length == 0) return songs.copy();

		var out:Array<ODSongMeta> = [];
		for (song in songs)
		{
			if (song.name.toLowerCase().contains(q) || song.folder.contains(q) || song.character.toLowerCase().contains(q))
				out.push(song);
		}
		return out;
	}

	public static function get(index:Int):Null<ODSongMeta>
	{
		if (index < 0 || index >= songs.length) return null;
		return songs[index];
	}

	public static function count():Int
	{
		return songs.length;
	}

	public static function isLoaded():Bool
	{
		return loaded;
	}
}
