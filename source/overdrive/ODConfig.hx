package overdrive;

/**
 * Central Overdrive configuration (master specification C3).
 *
 * Nothing in this file may hold a secret. Service endpoints are public URLs;
 * any key belongs in the server environment, never in the client binary.
 */
typedef ODServices = {
	var apiBase:String;      // auth, accounts, saves, currency, matches
	var contentBase:String;  // song packages and audio
	var portalBase:String;   // human-facing Song Portal website
}

class ODConfig
{
	public static inline var ENGINE_NAME:String = 'Overdrive Engine';
	public static inline var ENGINE_VERSION:String = '0.1.0';

	// The inherited base. The commit hash is the only trustworthy identifier:
	// upstream's gitVersion.txt says 1.0.4 while Project.xml says 0.2.8.
	public static inline var BASE_NAME:String = 'Psych Engine 1.0.4';
	public static inline var BASE_COMMIT:String = '5c67ced49e5a98535298a6daa3f8f4ec79ac8399';

	/**
	 * Build profile. Selected with -D od_production or -D od_staging; everything
	 * else is development. Development never talks to a production service.
	 */
	public static var profile:String = #if od_production 'production' #elseif od_staging 'staging' #else 'development' #end;

	public static var services:ODServices = servicesFor(profile);

	static function servicesFor(profile:String):ODServices
	{
		return switch (profile)
		{
			case 'production':
				{
					apiBase: 'https://api.overdrive-engine.invalid/v1',
					contentBase: 'https://content.overdrive-engine.invalid/v1',
					portalBase: 'https://overdrive-engine.invalid'
				};
			case 'staging':
				{
					apiBase: 'https://api-staging.overdrive-engine.invalid/v1',
					contentBase: 'https://content-staging.overdrive-engine.invalid/v1',
					portalBase: 'https://staging.overdrive-engine.invalid'
				};
			default:
				{
					// Loopback only: a development build must never name a public host.
					apiBase: 'http://127.0.0.1:8787/api/v1',
					contentBase: 'http://127.0.0.1:8787/content/v1',
					portalBase: 'http://127.0.0.1:3000'
				};
		}
	}

	/**
	 * Feature availability. A false flag is not a stub: the UI must present the
	 * feature as unavailable rather than offering a button that does nothing.
	 *
	 * Every backend-dependent flag stays false until a service actually exists.
	 */
	public static var features(default, null):Map<String, Bool> = [
		'accounts' => false,
		'cloud_saves' => false,
		'song_portal' => false,
		'community_upload' => false,
		'multiplayer' => false,
		'friends' => false,
		'messaging' => false,
		'clans' => false,
		'demonlist' => false,
		'daily_challenge' => false,
		'weekly_demon' => false,
		'events' => false,
		// Local-only systems that need no deployment.
		'skins' => false,
		'chart_editor' => true
	];

	public static function hasFeature(id:String):Bool
	{
		return features.exists(id) && features.get(id) == true;
	}

	public static function setFeature(id:String, enabled:Bool):Void
	{
		features.set(id, enabled);
	}

	// Network timeouts, in milliseconds. Short enough that a menu never hangs.
	public static inline var TIMEOUT_CONNECT_MS:Int = 5000;
	public static inline var TIMEOUT_REQUEST_MS:Int = 10000;
	public static inline var TIMEOUT_UPLOAD_MS:Int = 120000;

	/**
	 * True when the build has no reachable backend at all. Screens use this to
	 * show an offline state instead of an error dialog for every tile.
	 */
	public static function backendConfigured():Bool
	{
		return services.apiBase.indexOf('.invalid') == -1;
	}

	public static function describe():String
	{
		return '${ENGINE_NAME} v${ENGINE_VERSION} (${profile}) · ${BASE_NAME} @ ${BASE_COMMIT.substr(0, 7)}';
	}
}
