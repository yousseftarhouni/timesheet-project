package tn.esprit.spring.control;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import tn.esprit.spring.entities.User;
import tn.esprit.spring.services.IUserService;

// userRestControl
@RestController // = @Controller + @ResponseBody
@RequestMapping("/user")
public class UserRestControl {

	@Autowired
	IUserService userService;

	@PersistenceContext
	EntityManager entityManager;

	// URL : http://localhost:????/????/????/retrieve-all-users
	@GetMapping("/retrieve-all-users")
	public List<User> retrieveAllUsers() {
		return userService.retrieveAllUsers();

	}

	@GetMapping("/retrieve-user/{user-id}")
	public User retrieveUser(@PathVariable("user-id") String userId) {
		return userService.retrieveUser(userId);
	}

	// Ajouter User : http://localhost:????/timesheet-devops/add-user
	@PostMapping("/add-user")
	public User addUser(@RequestBody User u) {
		User user = userService.addUser(u);
		return user;
	}

	// Supprimer User :
	// http://localhost:????/timesheet-devops/remove-user/{user-id}
	@DeleteMapping("/remove-user/{user-id}")
	public void removeUser(@PathVariable("user-id") String userId) {
		userService.deleteUser(userId);
	}

	// Modifier User
	// http://localhost:????/timesheet-devops/modify-user
	@PutMapping("/modify-user")
	public User updateUser(@RequestBody User user) {
		return userService.updateUser(user);
	}

	// ======================================================================
	// VULNERABILITE DEMO (DevSecOps) : SQL Injection - CWE-89
	// Detectee par : SonarQube (regle java:S2077 - "SQL queries should not be
	// vulnerable to injection attacks") et testable via OWASP ZAP / Gauntlt.
	// NE JAMAIS reproduire ce pattern en production : utiliser une requete
	// parametree (PreparedStatement / @Param) a la place de la concatenation.
	// URL demo : http://localhost:????/user/search-by-name?name=anything
	// Payload demo : ?name=x' OR '1'='1
	// ======================================================================
	@GetMapping("/search-by-name")
	public List<?> searchUserByNameVulnerable(@RequestParam("name") String name) {
		String sql = "SELECT * FROM T_USER WHERE first_name = '" + name + "'";
		Query query = entityManager.createNativeQuery(sql, User.class);
		return query.getResultList();
	}

}
