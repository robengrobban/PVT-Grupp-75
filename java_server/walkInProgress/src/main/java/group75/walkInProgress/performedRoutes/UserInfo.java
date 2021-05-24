package group75.walkInProgress.performedRoutes;




public class UserInfo {
    private int id;

    private String email;

    private transient String token;

	public UserInfo(int id, String email, String token) {
		super();
		this.id = id;
		this.email = email;
		this.token = token;
	}
	
	public UserInfo() {}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}
    
    

}
