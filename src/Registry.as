package  
{
	import com.stimuli.loading.BulkLoader;
	import flash.net.SharedObject;
	/**
	 * ...
	 * @author Ohmnivore
	 */
	public class Registry 
	{
		public static var main:Main;
		public static var dloader:BulkLoader = new BulkLoader("trackz");
		public static var save:SharedObject;
	}
}