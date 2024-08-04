package android;

#if (!android && !native && macro)
#error 'extension-androidtools is not supported on your current platform'
#end
import android.jni.JNICache;
import android.Permissions;
import haxe.io.Path;
import lime.app.Event;
import lime.system.JNI;
import lime.utils.Log;

/**
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class Tools
{
	/**
	 * Launches a app by the `packageName`.
	 */
	public static function launchPackage(packageName:String, requestCode:Int = 1):Void
	{
		var launchPackage_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'launchPackage', '(Ljava/lang/String;I)V');
		launchPackage_jni(packageName, requestCode);
	}

	public static function getExternalStorageDirectory():String
	{
		var getExternalStorageDirectory_jni = JNI.createStaticMethod("org/haxe/extension/Tools", "getExternalStorageDirectory", "()Ljava/lang/String;");
		return getExternalStorageDirectory_jni();
	}

	/**
	 * Returns `true` If the device have root.
	 * Returns `false` If the device doesn't have root or there`s a error while the process is runned.
	 */
	public static function isRooted():Bool
	{
		var isRooted_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'isRooted', '()Z');
		return isRooted_jni();
	}

	/**
	 * Returns whether the device is running Android TV.
	 */
	public static function isAndroidTV():Bool
	{
		var isAndroidTV_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'isAndroidTV', '()Z');
		return isAndroidTV_jni();
	}

	/**
	 * Returns whether the device is a ChromeBook.
	 */
	public static function isChromeBook():Bool
	{
		var isChromeBook_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'isChromeBook', '()Z');
		return isChromeBook_jni();
	}

	/**
	 * Sets brightness of the main window, max is 1 and min is 0.
	 */
	public static function setBrightness(screenBrightness:Float):Void
	{
		if (screenBrightness > 1)
			screenBrightness = 1;
		else if (screenBrightness < 0)
			screenBrightness = 0;

		var setBrightness_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'setBrightness', '(F)V');
		setBrightness_jni(screenBrightness);
	}

	/**
	 * Shows an alert dialog with optional positive and negative buttons.
	 *
	 * @param title The title of the alert dialog.
	 * @param message The message content of the alert dialog.
	 * @param positiveButton Optional data for the positive button.
	 * @param negativeButton Optional data for the negative button.
	 */
	public static function showAlertDialog(title:String, message:String, ?positiveButton:ButtonData, ?negativeButton:ButtonData):Void
	{
		if (positiveButton == null)
			positiveButton = {name: null, func: null};

		if (negativeButton == null)
			negativeButton = {name: null, func: null};

		JNICache.createStaticMethod('org/haxe/extension/Tools', 'showAlertDialog',
			'(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lorg/haxe/lime/HaxeObject;Ljava/lang/String;Lorg/haxe/lime/HaxeObject;)V')(title, message,
				positiveButton.name, new ButtonListener(positiveButton.func), negativeButton.name, new ButtonListener(negativeButton.func));
	}

	/**
	 * Return the brightness of the main window.
	 */
	public static function getBrightness():Float
	{
		var getBrightness_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'getBrightness', '()F');
		return getBrightness_jni();
	}

	/**
	 * Makes the Device to vibrate, the time is in miliseconds btw.
	 */
	public static function vibrate(duration:Int, period:Int = 0):Void
	{
		var vibrate_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'vibrate', '(II)V');

		if (Permissions.getGrantedPermissions().contains(Permissions.VIBRATE))
			vibrate_jni(duration, period);
		else
			Log.warn("VIBRATE permission isn't granted, we can't vibrate the device.");
	}
}

/**
 * Data structure for defining button properties in an alert dialog.
 */
@:noCompletion
private typedef ButtonData =
{
	name:String,
	// The name or label of the button.
	func:Void->Void
	// The callback function to execute when the button is clicked.
}

/**
 * Listener class for handling button click events in an alert dialog.
 */
@:noCompletion
private class ButtonListener #if (lime >= "8.0.0") implements JNISafety #end
{
	private var onClickEvent:Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Creates a new button listener with a specified callback function.
	 *
	 * @param clickCallback The function to execute when the button is clicked.
	 */
	public function new(clickCallback:Void->Void):Void
	{
		if (clickCallback != null)
			onClickEvent.add(clickCallback);
	}

	#if (lime >= "8.0.0")
	@:runOnMainThread
	#end
	public function onClick():Void
	{
		onClickEvent.dispatch();
	}
}

