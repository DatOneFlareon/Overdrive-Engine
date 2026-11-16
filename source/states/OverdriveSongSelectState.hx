package states;

import backend.Difficulty;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import overdrive.ODRating;
import overdrive.songs.ODSongLibrary;
import overdrive.songs.ODSongMeta;
import overdrive.ui.ODButton;
import overdrive.ui.ODTheme;

/**
 * Overdrive song selection (master specification F1, Phase 3).
 *
 * One song at a time, big and central. Never loads chart or audio data for more
 * than the song about to be played.
 */
class OverdriveSongSelectState extends MusicBeatState
{
	var songs:Array<ODSongMeta> = [];
	var curSelected:Int = 0;
	var curDifficulty:Int = 0;
	var practiceMode:Bool = false;

	var busy:Bool = false;

	var panel:FlxSprite;
	var art:FlxSprite;
	var titleText:FlxText;
	var artistText:FlxText;
	var diffText:FlxText;
	var starText:FlxText;
	var recordText:FlxText;
	var pageText:FlxText;
	var statusText:FlxText;
	var modeText:FlxText;

	var prevBtn:ODButton;
	var nextBtn:ODButton;
	var modeBtn:ODButton;
	var playBtn:ODButton;

	override function create():Void
	{
		super.create();
		persistentUpdate = true;
		persistentDraw = true;
		FlxG.mouse.visible = true;

		ODSongLibrary.ensureLoaded();
		songs = ODSongLibrary.songs;

		buildLayout();
		refreshInfo();

		if (songs.length == 0)
		{
			statusText.text = 'No songs are available. Check that a week is installed and unlocked.';
			statusText.color = ODTheme.WARN;
		}
	}

	function buildLayout():Void
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, ODTheme.BG_DEEP);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.scrollFactor.set();
		add(bg);

		var header:FlxText = new FlxText(0, 26, FlxG.width, 'PLAY', 30);
		header.setFormat(ODTheme.font(), 30, ODTheme.TEXT, CENTER);
		header.scrollFactor.set();
		add(header);

		panel = new FlxSprite(0, 92).makeGraphic(640, 330, ODTheme.SURFACE);
		panel.screenCenter(X);
		panel.scrollFactor.set();
		add(panel);

		// Placeholder art block. There is no Overdrive artwork yet, and this
		// screen says so instead of loading a borrowed image.
		art = new FlxSprite(panel.x + 20, panel.y + 20).makeGraphic(240, 240, ODTheme.SURFACE_HIGH);
		art.scrollFactor.set();
		add(art);

		titleText = new FlxText(panel.x + 280, panel.y + 24, 340, '', 26);
		titleText.setFormat(ODTheme.font(), 26, ODTheme.TEXT, LEFT);
		titleText.scrollFactor.set();
		add(titleText);

		artistText = new FlxText(panel.x + 280, panel.y + 66, 340, '', 14);
		artistText.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, LEFT);
		artistText.scrollFactor.set();
		add(artistText);

		diffText = new FlxText(panel.x + 280, panel.y + 104, 340, '', 18);
		diffText.setFormat(ODTheme.font(), 18, ODTheme.ACCENT, LEFT);
		diffText.scrollFactor.set();
		add(diffText);

		starText = new FlxText(panel.x + 280, panel.y + 132, 340, '', 18);
		starText.setFormat(ODTheme.font(), 18, ODTheme.ACCENT_GOLD, LEFT);
		starText.scrollFactor.set();
		add(starText);

		recordText = new FlxText(panel.x + 280, panel.y + 176, 340, '', 14);
		recordText.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, LEFT);
		recordText.scrollFactor.set();
		add(recordText);

		pageText = new FlxText(0, panel.y + 344, FlxG.width, '', 14);
		pageText.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, CENTER);
		pageText.scrollFactor.set();
		add(pageText);

		prevBtn = new ODButton('prev', panel.x - 96, panel.y + 140, 76, 76, '<', ODTheme.ACCENT);
		prevBtn.onClick = function() changeSong(-1);
		prevBtn.onHover = null;
		prevBtn.addTo(this);

		nextBtn = new ODButton('next', panel.x + panel.width + 20, panel.y + 140, 76, 76, '>', ODTheme.ACCENT);
		nextBtn.onClick = function() changeSong(1);
		nextBtn.addTo(this);

		modeBtn = new ODButton('mode', panel.x + 280, panel.y + 236, 156, 56, 'NORMAL', ODTheme.ACCENT_LIME);
		modeBtn.onClick = toggleMode;
		modeBtn.addTo(this);

		playBtn = new ODButton('play', panel.x + 452, panel.y + 236, 168, 56, 'PLAY [ENTER]', ODTheme.ACCENT_WARM);
		playBtn.onClick = startSong;
		playBtn.addTo(this);

		modeText = new FlxText(0, panel.y + 300, FlxG.width, '', 14);
		modeText.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, CENTER);
		modeText.scrollFactor.set();
		add(modeText);

		statusText = new FlxText(0, FlxG.height - 74, FlxG.width, '', 16);
		statusText.setFormat(ODTheme.font(), 16, ODTheme.TEXT_DIM, CENTER);
		statusText.scrollFactor.set();
		add(statusText);

		var back:FlxText = new FlxText(ODTheme.GAP_M, FlxG.height - 34, 0, 'BACKSPACE: return to menu', 14);
		back.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DISABLED, LEFT);
		back.scrollFactor.set();
		add(back);
	}

	// -------------------------------------------------------------------- state

	function current():Null<ODSongMeta>
	{
		if (curSelected < 0 || curSelected >= songs.length) return null;
		return songs[curSelected];
	}

	function currentDifficultyName():String
	{
		var song:Null<ODSongMeta> = current();
		if (song == null || song.difficulties.length == 0) return 'Normal';
		curDifficulty = Std.int(FlxMath.wrap(curDifficulty, 0, song.difficulties.length - 1));
		return song.difficulties[curDifficulty];
	}

	function refreshInfo():Void
	{
		var song:Null<ODSongMeta> = current();

		if (song == null)
		{
			titleText.text = 'NO SONGS';
			artistText.text = '';
			diffText.text = '';
			starText.text = '';
			recordText.text = '';
			pageText.text = '0 / 0';
			playBtn.disable('Nothing to play');
			prevBtn.disable('Nothing to play');
			nextBtn.disable('Nothing to play');
			return;
		}

		playBtn.enable();
		if (songs.length > 1)
		{
			prevBtn.enable();
			nextBtn.enable();
		}
		else
		{
			prevBtn.disable('Only one song');
			nextBtn.disable('Only one song');
		}

		var diffName:String = currentDifficultyName();
		var category:Null<String> = ODRating.categoryForDifficulty(diffName);

		titleText.text = song.name;
		artistText.text = 'Artist: not in chart metadata';
		diffText.text = diffName;
		starText.text = category == null ? 'Unrated (no official band for this difficulty)' : ODRating.bandLabel(category);
		starText.color = category == null ? ODTheme.TEXT_DISABLED : ODTheme.ACCENT_GOLD;
		recordText.text = 'Best score: ' + Highscore.getScore(song.folder, curDifficulty) + '   ·   Completion: not tracked by Psych 1.0.4';
		pageText.text = (curSelected + 1) + ' / ' + songs.length;

		art.color = song.colour;
		panel.color = ODTheme.SURFACE;
		modeText.text = practiceMode ? 'Practice: no competitive record will be written' : 'Normal: results count as a normal completion';
		modeText.color = practiceMode ? ODTheme.WARN : ODTheme.TEXT_DIM;
		modeBtn.setLabel(practiceMode ? 'PRACTICE' : 'NORMAL');
	}

	function changeSong(delta:Int):Void
	{
		if (songs.length == 0 || busy) return;
		curSelected = Std.int(FlxMath.wrap(curSelected + delta, 0, songs.length - 1));
		FlxG.sound.play(Paths.sound('scrollMenu'));
		refreshInfo();
	}

	function changeDifficulty(delta:Int):Void
	{
		var song:Null<ODSongMeta> = current();
		if (song == null || busy) return;

		curDifficulty = Std.int(FlxMath.wrap(curDifficulty + delta, 0, Math.max(0, song.difficulties.length - 1)));
		FlxG.sound.play(Paths.sound('scrollMenu'));
		refreshInfo();
	}

	function toggleMode():Void
	{
		practiceMode = !practiceMode;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		refreshInfo();
	}

	// ------------------------------------------------------------------ loading

	function startSong():Void
	{
		if (busy) return;

		var song:Null<ODSongMeta> = current();
		if (song == null)
		{
			statusText.text = 'Nothing to play.';
			statusText.color = ODTheme.WARN;
			return;
		}

		busy = true;
		statusText.text = 'Loading ' + song.name + '...';
		statusText.color = ODTheme.WARN;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxG.mouse.visible = false;

		var week:WeekData = WeekData.weeksLoaded.get(song.week);
		if (week != null)
		{
			WeekData.setDirectoryFromWeek(week);
			Difficulty.loadFromWeek(week);
		}

		var diffIndex:Int = curDifficulty;

		try
		{
			var chart:String = Highscore.formatSong(song.folder, diffIndex);
			Song.loadFromJson(chart, song.folder);

			PlayState.isStoryMode = false;
			PlayState.chartingMode = false;
			PlayState.storyDifficulty = diffIndex;

			// The inherited practice switch. PracticeState reads this exact key.
			ClientPrefs.data.gameplaySettings.set('practice', practiceMode);

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

	// --------------------------------------------------------------------- loop

	override function update(elapsed:Float):Void
	{
		if (!busy)
		{
			prevBtn.update(elapsed);
			nextBtn.update(elapsed);
			modeBtn.update(elapsed);
			playBtn.update(elapsed);

			if (controls.UI_LEFT_P) changeSong(-1);
			if (controls.UI_RIGHT_P) changeSong(1);
			if (controls.UI_UP_P) changeDifficulty(-1);
			if (controls.UI_DOWN_P) changeDifficulty(1);

			if (controls.ACCEPT) startSong();

			if (controls.BACK)
			{
				busy = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new OverdriveMainMenuState());
				return;
			}
		}

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		super.update(elapsed);
	}
}
