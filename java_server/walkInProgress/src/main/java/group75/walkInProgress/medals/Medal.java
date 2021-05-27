package group75.walkInProgress.medals;


import java.time.LocalDateTime;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Medal {
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Integer id;
	
	
	private int userId;
	private String type;
	private int value;
	private LocalDateTime timeEarned;
	
	Medal(){}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public int getValue() {
		return value;
	}

	public void setValue(int value) {
		this.value = value;
	}

	public LocalDateTime getTimeEarned() {
		return timeEarned;
	}

	public void setTimeEarned(LocalDateTime timeEarned) {
		this.timeEarned = timeEarned;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((timeEarned == null) ? 0 : timeEarned.hashCode());
		result = prime * result + ((type == null) ? 0 : type.hashCode());
		result = prime * result + userId;
		result = prime * result + value;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Medal other = (Medal) obj;
		if (timeEarned == null) {
			if (other.timeEarned != null)
				return false;
		} else if (!timeEarned.equals(other.timeEarned))
			return false;
		if (type == null) {
			if (other.type != null)
				return false;
		} else if (!type.equals(other.type))
			return false;
		if (userId != other.userId)
			return false;
		if (value != other.value)
			return false;
		return true;
	}


	
	

}
