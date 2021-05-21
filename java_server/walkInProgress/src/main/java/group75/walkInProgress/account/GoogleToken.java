package group75.walkInProgress.account;

public class GoogleToken {

	String azp;
	String aud;
	String sub;
	String scope;
	String exp;
	String expires_in;
	String email;
	String email_verified;
	String access_type;

	public GoogleToken() {}

	public String getAzp() {
		return azp;
	}

	public void setAzp(String azp) {
		this.azp = azp;
	}

	public String getAud() {
		return aud;
	}

	public void setAud(String aud) {
		this.aud = aud;
	}

	public String getSub() {
		return sub;
	}

	public void setSub(String sub) {
		this.sub = sub;
	}

	public String getScope() {
		return scope;
	}

	public void setScope(String scope) {
		this.scope = scope;
	}

	public String getExp() {
		return exp;
	}

	public void setExp(String exp) {
		this.exp = exp;
	}

	public String getExpires_in() {
		return expires_in;
	}

	public void setExpires_in(String expires_in) {
		this.expires_in = expires_in;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getEmail_verified() {
		return email_verified;
	}

	public void setEmail_verified(String email_verified) {
		this.email_verified = email_verified;
	}

	public String getAccess_type() {
		return access_type;
	}

	public void setAccess_type(String access_type) {
		this.access_type = access_type;
	}

	@Override
	public String toString() {
		return "GoogleToken{" +
				"azp='" + azp + '\'' +
				", aud='" + aud + '\'' +
				", sub='" + sub + '\'' +
				", scope='" + scope + '\'' +
				", exp='" + exp + '\'' +
				", expires_in='" + expires_in + '\'' +
				", email='" + email + '\'' +
				", email_verified='" + email_verified + '\'' +
				", access_type='" + access_type + '\'' +
				'}';
	}
}
