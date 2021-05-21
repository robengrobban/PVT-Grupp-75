package group75.walkInProgress.account;

import org.springframework.data.annotation.Transient;

import javax.persistence.*;
import java.io.Serializable;

@Entity
class Account implements Serializable {

    // Instance variables
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO)
    private int id;

    @Column(unique=true, nullable=false)
    private String email;

    @Transient
    private String token;

    // Constructors
    public Account() {}

    // Methods
    public int getId() {
        return this.id;
    }

    public String getEmail() {
        return this.email;
    }

    public void setId(int id) {
        this.id = id;
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

    @Override
    public String toString() {
        return "Account{" +
                "id=" + id +
                ", email='" + email + '\'' +
                ", token='" + token + '\'' +
                '}';
    }
}
