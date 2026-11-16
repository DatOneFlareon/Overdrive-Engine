package states;

import backend.Difficulty;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import overdrive.ODRating;
import overdrive.songs.ODSongLibrary;
import overdrive.songs.ODSongMeta;
import overdrive.ui.ODTheme;

/**
 * The full local song library (master specification 4, K12 groundwork).
 *
 * Paged on purpose: one page of rows exists at a time, so adding a thousand
 * songs does not add a thousand display objects.
 */
class OverdriveSongLibraryState extends MusicBeatState
{
	static inline var PER_PAGE:Int = 10;
	static inline var ALLOWED_CHARS:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_';

	var all:Array<ODSongMeta> = [];
	var filtered:Array<ODSongMeta> = [];
	var query:String = '';
	var categoryFilter:String = 'All';
	var selected:Int = 0;

	var rows:Array<FlxText> = [];
	var queryText:FlxText;
	var countText:FlxText;
	var pageText:FlxText;
	var statusText:FlxText;

	var busy:Bool = false;

	override function create():Void
	{
		super.create();
		persistentUpdate = true;
		persistentDraw = true;
		FlxG.mouse.visible = true;

		ODSongLibrary.ensureLoaded();
		all = ODSongLibrary.songs;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, ODTheme.BG_DEEP);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.scrollFactor.set();
		add(bg);

		var header:FlxText = new FlxText(0, 22, FlxG.width, 'SONGS', 30);
		header.setFormat(ODTheme.font(), 30, ODTheme.TEXT, CENTER);
		header.scrollFactor.set();
		add(header);

		queryText = new FlxText(ODTheme.GAP_L, 74, FlxG.width - ODTheme.GAP_L * 2, '', 18);
		queryText.setFormat(ODTheme.font(), 18, ODTheme.ACCENT, LEFT);
		queryText.scrollFactor.set();
		add(queryText);

		countText = new FlxText(0, 100, FlxG.width - ODTheme.GAP_L, '', 14);
		countText.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, RIGHT);
		countText.scrollFactor.set();
		add(countText);

		for (i in 0...PER_PAGE)
		{
			var row:FlxText = new FlxText(ODTheme.GAP_L, 132 + i * 40, FlxG.width - ODTheme.GAP_L * 2, '', 18);
			row.setFormat(ODTheme.font(), 18, ODTheme.TEXT_DIM, LEFT);
			row.scrollFactor.set();
			add(row);
			rows.push(row);
		}

		pageText = new FlxText(0, FlxG.height - 96, FlxG.width, '', 14);
		pageText.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, CENTER);
		pageText.scrollFactor.set();
		add(pageText);

		statusText = new FlxText(0, FlxG.height - 70, FlxG.width, '', 16);
		statusText.setFormat(ODTheme.font(), 16, ODTheme.TEXT_DIM, CENTER);
		statusText.scrollFactor.set();
		add(statusText);

		var help:FlxText = new FlxText(ODTheme.GAP_M, FlxG.height - 36, 0, 'type to search  ·  UP/DOWN select  ·  LEFT/RIGHT page  ·  TAB filter  ·  ENTER play  ·  BACKSPACE menu', 13);
		help.setFormat(ODTheme.font(), 13, ODTheme.TEXT_DISABLED, LEFT);
		help.scrollFactor.set();
		add(help);

		refilter(true);
	}

	// ------------------------------------------------------------------ filtering

	function refilter(resetSelection:Bool = false):Void
	{
		filtered = [];
		for (song in ODSongLibrary.search(query))
			if (matchesCategory(song, categoryFilter)) filtered.push(song);

		if (resetSelection) selected = 0;
		if (selected >= filtered.length) selected = Std.int(Math.max(0, filtered.length - 1));

		redraw();
	}

	function matchesCategory(song:ODSongMeta, category:String):Bool
	{
		if (category == 'All') return true;
		for (diff in song.difficulties)
			if (ODRating.categoryForDifficulty(diff) == category) return true;
		return false;
	}

	function redraw():Void
	{
		var page:Int = filtered.length == 0 ? 0 : Std.int(selected / PER_PAGE);
		var pages:Int = Std.int(Math.max(1, Math.ceil(filtered.length / PER_PAGE)));
		var start:Int = page * PER_PAGE;

		for (i in 0...rows.length)
		{
			var index:Int = start + i;
			var row:FlxText = rows[i];

			if (index >= filtered.length)
			{
				row.text = '';
				continue;
			}

			var song:ODSongMeta = filtered[index];
			var marker:String = index == selected ? '> ' : '  ';
			row.text = marker + song.name + '   ' + song.difficulties.join(' / ');
			row.color = index == selected ? ODTheme.ACCENT : ODTheme.TEXT_DIM;
		}

		countText.text = filtered.length + ' of ' + all.length + ' songs';
		pageText.text = 'page ' + (page + 1) + ' / ' + pages + '   ·   filter: ' + categoryFilter;
		queryText.text = 'Search: ' + query + (query.length == 0 ? '_' : '');

		if (filtered.length == 0)
		{
			statusText.text = all.length == 0 ? 'No songs installed.' : 'No songs match that search.';
			statusText.color = ODTheme.WARN;
		}
		else if (!busy)
		{
			statusText.text = '';
		}
	}

	// ------------------------------------------------------------------ playback

	function playSelected():Void
	{
		if (busy || filtered.length == 0) return;

		var song:ODSongMeta = filtered[selected];
		var diffIndex:Int = defaultDifficultyIndex(song);

		busy = true;
		statusText.text = 'Loading ' + song.name + '...';
		statusText.color = ODTheme.WARN;
		FlxG.mouse.visible = false;

		var week:WeekData = WeekData.weeksLoaded.get(song.week);
		if (week != null)
		{
			WeekData.setDirectoryFromWeek(week);
			Difficulty.loadFromWeek(week);
		}

		try
		{
			var chart:String = Highscore.formatSong(song.folder, diffIndex);
			Song.loadFromJson(chart, song.folder);

			PlayState.isStoryMode = false;
			PlayState.chartingMode = false;
			PlayState.storyDifficulty = diffIndex;
			ClientPrefs.data.gameplaySettings.set('practice', false);

			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
		}
		catch (e:haxe.Exception)
		{
			busy = false;
			statusText.text = 'Could not load chart: ' + e.message;
			statusText.color = ODTheme.ERROR;
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	/** Prefer Normal, then the first difficulty the week declares. */
	static function defaultDifficultyIndex(song:ODSongMeta):Int
	{
		for (i in 0...song.difficulties.length)
			if (song.difficulties[i].toLowerCase() == 'normal') return i;
		return 0;
	}

	// ---------------------------------------------------------------------- loop

	override function update(elapsed:Float):Void
	{
		if (!busy)
		{
			var total:Int = filtered.length;

			if (total > 0)
			{
				if (controls.UI_DOWN_P)
				{
					selected = Std.int(FlxMath.wrap(selected + 1, 0, total - 1));
					FlxG.sound.play(Paths.sound('scrollMenu'));
					redraw();
				}
				if (controls.UI_UP_P)
				{
					selected = Std.int(FlxMath.wrap(selected - 1, 0, total - 1));
					FlxG.sound.play(Paths.sound('scrollMenu'));
					redraw();
				}
				if (controls.UI_RIGHT_P)
				{
					selected = Std.int(Math.min(total - 1, selected + PER_PAGE));
					FlxG.sound.play(Paths.sound('scrollMenu'));
					redraw();
				}
				if (controls.UI_LEFT_P)
				{
					selected = Std.int(Math.max(0, selected - PER_PAGE));
					FlxG.sound.play(Paths.sound('scrollMenu'));
					redraw();
				}
			}

			if (FlxG.keys.justPressed.TAB)
			{
				cycleFilter();
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (FlxG.keys.justPressed.BACKSPACE && query.length > 0)
			{
				query = query.substring(0, query.length - 1);
				refilter(true);
			}

			var key:FlxKey = FlxG.keys.firstJustPressed();
			if (key != FlxKey.NONE)
			{
				var name:String = Std.string(key);
				if (name.length == 1 && ALLOWED_CHARS.contains(name))
				{
					query += name.toLowerCase();
					refilter(true);
				}
			}

			if (controls.ACCEPT) playSelected();

			if (controls.BACK && !FlxG.keys.justPressed.BACKSPACE)
			{
				busy = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new OverdriveMainMenuState());
				return;
			}
		}

		super.update(elapsed);
	}

	function cycleFilter():Void
	{
		var options:Array<String> = ['All'];
		for (category in ODRating.categories()) options.push(category);

		var index:Int = options.indexOf(categoryFilter);
		index = index < 0 ? 0 : Std.int((index + 1) % options.length);
		categoryFilter = options[index];
		refilter(true);
	}
}
