// HELP WITH CODE ON LINE 95!!!
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

class PlayState extends FlxUIState
{
	public var symbols:FlxSpriteGroup;
	public var textInput:FlxUIInputText;

	public var DEFAULT_TEXT:String = "test text";

	override public function create()
	{
		FlxG.camera.bgColor = FlxColor.PURPLE;

		var bg:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.menuBG__png);
		bg.scrollFactor.set();
		bg.color = 0xFF3B3B3B;
		add(bg);

		symbols = new FlxSpriteGroup(0, 0);
		symbols.screenCenter(FlxAxes.XY);
		add(symbols);

		writeText(DEFAULT_TEXT);

		addSongBox();

		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = true;

		super.create();
	}

	var UI_box:FlxUITabMenu;

	function addSongBox()
	{
		var tabs = [{name: 'Week Editor', label: 'Week Editor'}];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(230, 100);
		UI_box.x = FlxG.width - UI_box.width - 40;
		UI_box.y = 10;
		UI_box.scrollFactor.set();
		UI_box.alpha = 0.8;
		addSongUI();
		add(UI_box);
	}

	var weekInput:FlxUIInputText;
	var colorStepperR:FlxUINumericStepper;
	var colorStepperG:FlxUINumericStepper;
	var colorStepperB:FlxUINumericStepper;
	var rgbColorText:FlxText; // to make it more cool
	var saveBtn:FlxButton;

	function addSongUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Week Editor";

		weekInput = new FlxUIInputText(10, 30, 80, null, 8);

		colorStepperR = new FlxUINumericStepper(10, 60, 1, 255, 0, 255);

		colorStepperG = new FlxUINumericStepper(colorStepperR.x + colorStepperR.width + 18, 60, 1, 255, 0, 255);

		colorStepperB = new FlxUINumericStepper(colorStepperG.x + colorStepperG.width + 18, 60, 1, 255, 0, 255);

		rgbColorText = new FlxText(colorStepperG.x, colorStepperG.y - 16, FlxG.width, "RGB Color");
		setTint(FlxColor.WHITE);

		saveBtn = new FlxButton(130, 25, "Save image", function()
		{
			// Here, I need your help with getting bitmap data of all symbols
			// saveImage(<data here>);
		});

		tab_group.add(new FlxText(weekInput.x, weekInput.y - 18, weekInput.width, 'Week name:'));
		tab_group.add(rgbColorText);
		tab_group.add(weekInput);
		tab_group.add(saveBtn);
		tab_group.add(colorStepperR);
		tab_group.add(colorStepperG);
		tab_group.add(colorStepperB);
		UI_box.addGroup(tab_group);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (sender == weekInput)
			{
				if (weekInput.text != '')
					writeText(weekInput.text, 0, 0, true);
				else
					writeText(DEFAULT_TEXT, 0, 0, true);
				weekInput.hasFocus = true;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			if (sender == colorStepperR || sender == colorStepperG || sender == colorStepperB)
			{
				setTint(FlxColor.fromRGB(Std.int(colorStepperR.value), Std.int(colorStepperG.value), Std.int(colorStepperB.value)));
			}
		}
	}

	function writeText(text:String, x:Float = 0, y:Float = 0, overrideText:Bool = false):Array<FlxSprite>
	{
		var idk:Array<FlxSprite> = [];
		if (overrideText)
			symbols.clear();
		for (i in 0...text.split("").length)
		{
			if (i == 0)
			{
				var test = createSymbol(text.split("")[i], x, y);
				idk.push(test);
			}
			else
			{
				var allWidths:Array<Int> = [for (i in 0...idk.length) idk[i].frameWidth];
				var ik:Int = 0;
				for (i in 0...allWidths.length)
					ik += allWidths[i];
				var test = createSymbol(text.split("")[i], x + ik, y);
				idk.push(test);
			}
			symbols.add(idk[idk.length - 1]);
		}
		symbols.screenCenter(FlxAxes.XY);
		return idk;
	}

	function createSymbol(char:String, x:Float = 0, y:Float = 0):FlxSprite
	{
		char = char.toUpperCase(); // Because font doesn't support lowercase
		var words:Array<String> = [
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
		];
		var numbers:Array<String> = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
		var symbols:Array<String> = ['@', '-', "'", '"', '.', ',', ':', '?', '!', '$', '♪', '♥'];
		var animationName:String = '@'; // @ by default
		if (words.contains(char) || numbers.contains(char))
			animationName = char;
		if (symbols.contains(char))
			if (char == '@' || char == '-' || char == ',' || char == '.' || char == '$' || char == '♪')
				animationName = char;
			else if (char == "'")
				animationName = "quotation mark";
		if (char == '"')
			animationName = "double quotation mark";
		if (char == '.')
			animationName = "dot";
		if (char == ':')
			animationName = "double dot";
		if (char == '?')
			animationName = "question mark";
		if (char == '!')
			animationName = "exclamation point";

		if (char == ' ')
		{ // Very stupid way to handle spaces
			var symbol:FlxSprite = new FlxSprite(x, y).makeGraphic(35, 35, FlxColor.TRANSPARENT);
			symbol.antialiasing = true;
			symbol.useFramePixels = true;
			return symbol;
		}
		else
		{
			var symbol:FlxSprite = new FlxSprite(x, y).loadGraphic(AssetPaths.weekAlphabet__png);
			symbol.antialiasing = true;
			symbol.useFramePixels = true;
			symbol.frames = FlxAtlasFrames.fromSparrow(AssetPaths.weekAlphabet__png, AssetPaths.weekAlphabet__xml);
			symbol.animation.addByPrefix("symbol", animationName);
			symbol.animation.play("symbol");
			return symbol;
		}
	}

	function setTint(color:FlxColor)
	{
		symbols.color = color;
		if (rgbColorText != null)
		{
			rgbColorText.borderStyle = FlxTextBorderStyle.OUTLINE;
			rgbColorText.borderColor = color;
			rgbColorText.color = color.getInverted();
		}
	}

	function saveImage(bitmapData:BitmapData)
	{
		var b:ByteArray = new ByteArray();
		b = bitmapData.encode(bitmapData.rect, new PNGEncoderOptions(true), b);
		var file = new FileReference();
		file.save(b, (weekInput.text == '' ? DEFAULT_TEXT : weekInput.text) + ".png");
	}
}
