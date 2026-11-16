package overdrive.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import backend.ClientPrefs;
import overdrive.ui.ODTheme;

/**
 * A single reusable button (master specification D2).
 *
 * Lifecycle: construct, addTo(state), call update(elapsed) from the owning
 * state's update loop, call kill() before the state is destroyed.
 *
 * The owning screen owns selection. This component never moves focus by
 * itself; it only reports that the pointer is over it, via onHover, so the
 * screen can keep keyboard and mouse selection in agreement.
 */
class ODButton
{
	public var id:String;
	public var bg:FlxSprite;
	public var bar:FlxSprite;
	public var label:FlxText;
	public var badge:FlxText;

	public var onClick:Void->Void = null;
	public var onHover:Void->Void = null;

	/** Shown by the screen when the button is focused while unavailable. */
	public var reason:String = '';

	public var accentColor:FlxColor;

	public var enabled(default, set):Bool = true;
	public var focused(default, set):Bool = false;

	var hovered:Bool = false;
	var held:Bool = false;
	var width:Int;
	var height:Int;
	var dead:Bool = false;

	public function new(id:String, x:Float, y:Float, width:Int, height:Int, text:String, ?accent:FlxColor, ?onClick:Void->Void)
	{
		this.id = id;
		this.width = width;
		this.height = height;
		this.onClick = onClick;
		this.accentColor = accent == null ? ODTheme.ACCENT : accent;

		bg = new FlxSprite(x, y);
		bg.makeGraphic(width, height, ODTheme.BUTTON_IDLE);
		bg.antialiasing = ClientPrefs.data.antialiasing;

		bar = new FlxSprite(x, y + height - ODTheme.ACCENT_BAR);
		bar.makeGraphic(width, ODTheme.ACCENT_BAR, this.accentColor);

		label = new FlxText(x, y, width, text, 20);
		label.setFormat(ODTheme.font(), 20, ODTheme.TEXT, CENTER);
		label.y = y + (height - label.height) * 0.5;

		badge = new FlxText(x + width - 6, y + 4, 0, '', 12);
		badge.setFormat(ODTheme.font(), 12, ODTheme.TEXT_DISABLED, RIGHT);
		badge.visible = false;

		refresh();
	}

	public function addTo(state:FlxState):Void
	{
		state.add(bg);
		state.add(bar);
		state.add(label);
		state.add(badge);
	}

	public function update(elapsed:Float):Void
	{
		if (dead) return;

		var over:Bool = FlxG.mouse.overlaps(bg);
		if (over != hovered)
		{
			hovered = over;
			refresh();
			if (over && onHover != null) onHover();
		}

		if (!enabled)
		{
			held = false;
			return;
		}

		if (hovered && FlxG.mouse.justPressed)
		{
			held = true;
			refresh();
		}

		if (held && FlxG.mouse.justReleased)
		{
			held = false;
			refresh();
			// Re-checked on release: dragging off the button must not fire it.
			if (hovered && enabled && onClick != null) onClick();
		}
	}

	public function setLabel(text:String):Void
	{
		label.text = text;
	}

	/** Mark the button unavailable and say why, in one call. */
	public function disable(reason:String):Void
	{
		this.reason = reason;
		enabled = false;
	}

	public function enable():Void
	{
		reason = '';
		enabled = true;
	}

	public function kill():Void
	{
		dead = true;
		FlxTween.cancelTweensOf(bg);
		FlxTween.cancelTweensOf(label);
	}

	function set_enabled(value:Bool):Bool
	{
		enabled = value;
		refresh();
		return value;
	}

	function set_focused(value:Bool):Bool
	{
		if (focused == value)
			return value;

		focused = value;
		refresh();
		FlxTween.cancelTweensOf(label);
		FlxTween.tween(label, {alpha: value ? 1 : 0.86}, 0.1, {ease: FlxEase.quadOut});
		return value;
	}

	function refresh():Void
	{
		if (dead) return;

		if (!enabled)
		{
			bg.color = ODTheme.BUTTON_DISABLED;
			label.color = ODTheme.TEXT_DISABLED;
			bar.color = ODTheme.TEXT_DISABLED;
			bar.alpha = 0.35;
			badge.visible = reason.length > 0;
			badge.text = reason.length > 0 ? 'UNAVAILABLE' : '';
			return;
		}

		badge.visible = false;
		bar.color = accentColor;
		bar.alpha = (focused || hovered) ? 1 : 0.55;
		label.color = ODTheme.TEXT;

		if (held)
			bg.color = ODTheme.BUTTON_PRESSED;
		else if (focused || hovered)
			bg.color = ODTheme.BUTTON_HOVER;
		else
			bg.color = ODTheme.BUTTON_IDLE;

		if (focused)
			bar.alpha = 1;
	}
}
