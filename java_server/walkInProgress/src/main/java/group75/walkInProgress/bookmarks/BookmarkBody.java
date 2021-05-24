package group75.walkInProgress.bookmarks;

public class BookmarkBody {
	private String token;
	private RouteInfo routeInfo;
	public BookmarkBody(String token, RouteInfo routeInfo) {
		this.token = token;
		this.routeInfo = routeInfo;
	}
	public String getToken() {
		return token;
	}
	public RouteInfo getRouteInfo() {
		return routeInfo;
	}
	
	
}
