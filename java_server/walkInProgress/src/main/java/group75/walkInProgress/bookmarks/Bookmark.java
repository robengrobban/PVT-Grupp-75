package group75.walkInProgress.bookmarks;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;


@Entity
@Table(
	    uniqueConstraints=
	        @UniqueConstraint(columnNames={"userId", "routeinfo_id"})
	)
public class Bookmark {
	
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private int id;

	private Integer userId;
	
	@OneToOne(cascade= {CascadeType.PERSIST})
	@JoinColumn(name = "ROUTEINFO_ID")
	private RouteInfo routeInfo;
	
	public Bookmark() {}

	public Bookmark(Integer userID, RouteInfo routeInfo) {
		this.userId = userID;
		this.routeInfo = routeInfo;
	}
	
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public RouteInfo getRouteInfo() {
		return routeInfo;
	}

	public void setRouteInfo(RouteInfo routeInfo) {
		this.routeInfo = routeInfo;
	}

}
