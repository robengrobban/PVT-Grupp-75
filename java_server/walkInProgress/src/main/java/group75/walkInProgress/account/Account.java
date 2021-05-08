package group75.walkInProgress.account;

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

    @Override
    public String toString() {
        return "ID: " + this.id + "\tEMAIL: " + this.email;
    }

}
