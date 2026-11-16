package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import options.OptionsState;
import overdrive.ODConfig;
import overdrive.ui.ODTheme;
import overdrive.ui.ODButton;

/**
 * The Overdrive main menu (master specification Part E).
 *
 * Layout: logo, a large PLAY, SKINS and COMMUNITY, then a secondary row.
 *
 * Honesty rule: a tile whose system does not exist yet is created disabled and
 * carries the real reason. It is never wired to a screen that does nothing.
 */
class OverdriveMainMenuState extends MusicBeatState
{
	var buttons:Array<ODButton> = [];
	var grid:Array<Array<ODButton>> = [];
	var rowIdx:Int = 0;
	var colIdx:Int = 0;

	var hint:FlxText;
	var title:FlxText;
	var accents:Array<FlxSprite> = [];

	var timeAlive:Float = 0;
	var leaving:Bool = false;

	override function create():Void
	{
		super.create();

		persistentUpdate = true;
		persistentDraw = true;
		FlxG.mouse.visible = true;

		buildBackground();
		buildHeader();
		buildPrimary();
		buildSecondary();
		buildFooter();

		refreshFocus();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence('In the Menus', null);
		#end
	}

	// ---------------------------------------------------------------- background

	function buildBackground():Void
	{
		var top:FlxSprite = new FlxSprite().makeGraphic(1, 1, ODTheme.BG_DEEP);
		top.scale.set(FlxG.width, FlxG.height);
		top.updateHitbox();
		top.scrollFactor.set();
		add(top);

		// A single lighter band: cheap depth without an image asset.
		var band:FlxSprite = new FlxSprite().makeGraphic(1, 1, ODTheme.BG_MID);
		band.scale.set(FlxG.width, FlxG.height * 0.42);
		band.updateHitbox();
		band.y = FlxG.height * 0.58;
		band.alpha = 0.55;
		band.scrollFactor.set();
		add(band);

		// Thin geometric accents. They drift slowly; low quality mode stops them.
		var colours:Array<FlxColor> = [ODTheme.ACCENT, ODTheme.ACCENT_WARM, ODTheme.ACCENT_VIOLET];
		for (i in 0...3)
		{
			var bar:FlxSprite = new FlxSprite().makeGraphic(6, Std.int(FlxG.height), colours[i]);
			bar.x = FlxG.width * 0.14 + i * (FlxG.width * 0.34);
			bar.alpha = 0.22;
			bar.angle = 18;
			bar.scrollFactor.set();
			add(bar);
			accents.push(bar);
		}
	}

	function buildHeader():Void
	{
		title = new FlxText(0, 54, FlxG.width, 'OVERDRIVE', 76);
		title.setFormat(ODTheme.font(), 76, ODTheme.TEXT, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF04070F);
		title.scrollFactor.set();
		add(title);

		var sub:FlxText = new FlxText(0, 138, FlxG.width, ODConfig.ENGINE_NAME.toUpperCase() + '  ·  v' + ODConfig.ENGINE_VERSION, 18);
		sub.setFormat(ODTheme.font(), 18, ODTheme.ACCENT, CENTER);
		sub.scrollFactor.set();
		add(sub);
	}

	// ------------------------------------------------------------------- buttons

	function buildPrimary():Void
	{
		var playW:Int = 460;
		var row:Array<ODButton> = [];
		row.push(button('play', (FlxG.width - playW) * 0.5, 206, playW, ODTheme.BUTTON_HEIGHT_LARGE, 'PLAY', ODTheme.ACCENT, openFreeplay));
		grid.push(row);

		var pairW:Int = 260;
		var gap:Int = ODTheme.GAP_M;
		var pairTotal:Float = pairW * 2 + gap;
		var pairStart:Float = (FlxG.width - pairTotal) * 0.5;
		var second:Array<ODButton> = [];
		second.push(button('skins', pairStart, 348, pairW, ODTheme.BUTTON_HEIGHT, 'SKINS', ODTheme.ACCENT_LIME));
		second.push(button('community', pairStart + pairW + gap, 348, pairW, ODTheme.BUTTON_HEIGHT, 'COMMUNITY', ODTheme.ACCENT_WARM));
		grid.push(second);
	}

	function buildSecondary():Void
	{
		var labels:Array<String> = ['DAILY', 'QUESTS', 'DEMONLIST', 'PROFILE', 'SETTINGS', 'MORE GAMES'];
		var ids:Array<String> = ['daily', 'quests', 'demonlist', 'profile', 'settings', 'more'];
		var colours:Array<FlxColor> = [ODTheme.ACCENT_GOLD, ODTheme.ACCENT_VIOLET, ODTheme.ACCENT_WARM, ODTheme.ACCENT, ODTheme.ACCENT_LIME, ODTheme.ACCENT_GOLD];

		var w:Int = 168;
		var gap:Int = ODTheme.GAP_S;
		var total:Float = w * labels.length + gap * (labels.length - 1);
		var start:Float = (FlxG.width - total) * 0.5;

		var row:Array<ODButton> = [];
		for (i in 0...labels.length)
		{
			var b:ODButton = button(ids[i], start + i * (w + gap), 470, w, 56, labels[i], colours[i]);
			row.push(b);
		}
		grid.push(row);

		// SETTINGS is real; everything else states the actual blocker.
		for (b in row)
		{
			if (b.id == 'settings')
				b.onClick = openSettings;
			else if (b.id == 'daily')
				b.disable('Needs rotation service');
			else if (b.id == 'quests')
				b.disable('Quests not built');
			else if (b.id == 'demonlist')
				b.disable('Demonlist service not deployed');
			else if (b.id == 'profile')
				b.disable('Accounts not deployed');
			else if (b.id == 'more')
				b.disable('No other builds yet');
		}

		for (b in grid[1])
		{
			if (b.id == 'skins')
				b.disable('Skins system not built');
			else if (b.id == 'community')
				b.disable('Needs the Song Portal');
		}
	}

	function button(id:String, x:Float, y:Float, w:Int, h:Int, text:String, accent:FlxColor, ?onClick:Void->Void):ODButton
	{
		var b:ODButton = new ODButton(id, x, y, w, h, text, accent, onClick);
		b.onHover = function() { focusButton(b); };
		b.addTo(this);
		buttons.push(b);
		return b;
	}

	// --------------------------------------------------------------------- footer

	function buildFooter():Void
	{
		var who:FlxText = new FlxText(ODTheme.GAP_M, FlxG.height - 62, 0, 'LOCAL PROFILE  ·  NOT SIGNED IN', 14);
		who.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, LEFT);
		who.scrollFactor.set();
		add(who);

		var wallet:FlxText = new FlxText(ODTheme.GAP_M, FlxG.height - 40, 0, 'COINS —   ORBS —   KEYS —   TOKENS —', 14);
		wallet.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DISABLED, LEFT);
		wallet.scrollFactor.set();
		add(wallet);

		var build:FlxText = new FlxText(0, FlxG.height - 62, FlxG.width - ODTheme.GAP_M, ODConfig.ENGINE_NAME + ' v' + ODConfig.ENGINE_VERSION, 14);
		build.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DIM, RIGHT);
		build.scrollFactor.set();
		add(build);

		var base:FlxText = new FlxText(0, FlxG.height - 40, FlxG.width - ODTheme.GAP_M, ODConfig.BASE_NAME + ' @ ' + ODConfig.BASE_COMMIT.substr(0, 7), 14);
		base.setFormat(ODTheme.font(), 14, ODTheme.TEXT_DISABLED, RIGHT);
		base.scrollFactor.set();
		add(base);

		hint = new FlxText(0, FlxG.height - 96, FlxG.width, '', 16);
		hint.setFormat(ODTheme.font(), 16, ODTheme.TEXT_DIM, CENTER);
		hint.scrollFactor.set();
		add(hint);
	}

	// ---------------------------------------------------------------- navigation

	function focusButton(target:ODButton):Void
	{
		for (r in 0...grid.length)
			for (c in 0...grid[r].length)
				if (grid[r][c] == target)
				{
					rowIdx = r;
					colIdx = c;
					refreshFocus();
					return;
				}
	}

	function moveRow(delta:Int):Void
	{
		rowIdx = FlxMath.wrap(rowIdx + delta, 0, grid.length - 1);
		colIdx = Std.int(Math.min(colIdx, grid[rowIdx].length - 1));
		FlxG.sound.play(Paths.sound('scrollMenu'));
		refreshFocus();
	}

	function moveCol(delta:Int):Void
	{
		colIdx = FlxMath.wrap(colIdx + delta, 0, grid[rowIdx].length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));
		refreshFocus();
	}

	function refreshFocus():Void
	{
		for (r in 0...grid.length)
			for (c in 0...grid[r].length)
				grid[r][c].focused = (r == rowIdx && c == colIdx);

		var current:ODButton = grid[rowIdx][colIdx];
		if (!current.enabled)
		{
			hint.text = current.label.text + ' — unavailable: ' + current.reason;
			hint.color = ODTheme.WARN;
		}
		else
		{
			hint.text = current.id == 'play' ? 'Play the current song library' : 'Open ' + current.label.text;
			hint.color = ODTheme.TEXT_DIM;
		}
	}

	function activate():Void
	{
		var current:ODButton = grid[rowIdx][colIdx];
		if (!current.enabled)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			refreshFocus();
			return;
		}

		leaving = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxG.mouse.visible = false;
		FlxTween.tween(current.bg, {alpha: 0.35}, 0.18, {ease: FlxEase.quadOut});
		if (current.onClick != null) current.onClick();
	}

	function openFreeplay():Void
	{
		MusicBeatState.switchState(new FreeplayState());
	}

	function openSettings():Void
	{
		OptionsState.onPlayState = false;
		MusicBeatState.switchState(new OptionsState());
	}

	// ---------------------------------------------------------------------- loop

	override function update(elapsed:Float):Void
	{
		timeAlive += elapsed;

		if (!leaving)
		{
			for (b in buttons) b.update(elapsed);

			if (controls.UI_UP_P) moveRow(-1);
			if (controls.UI_DOWN_P) moveRow(1);
			if (controls.UI_LEFT_P) moveCol(-1);
			if (controls.UI_RIGHT_P) moveCol(1);

			if (controls.BACK)
			{
				leaving = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
				return;
			}

			if (controls.ACCEPT) activate();
		}

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if (!ClientPrefs.data.lowQuality)
		{
			for (i in 0...accents.length)
				accents[i].y = Math.sin(timeAlive * 0.25 + i) * 18;
		}

		super.update(elapsed);
	}

	override function beatHit():Void
	{
		super.beatHit();
		if (title != null && !ClientPrefs.data.lowQuality)
		{
			FlxTween.cancelTweensOf(title.scale);
			title.scale.set(1.03, 1.03);
			FlxTween.tween(title.scale, {x: 1, y: 1}, 0.22, {ease: FlxEase.quadOut});
		}
	}

	override function destroy():Void
	{
		for (b in buttons) b.kill();
		super.destroy();
	}
}
