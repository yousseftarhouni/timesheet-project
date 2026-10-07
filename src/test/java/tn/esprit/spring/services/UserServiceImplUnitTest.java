package tn.esprit.spring.services;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.when;

import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import tn.esprit.spring.entities.User;
import tn.esprit.spring.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
class UserServiceImplUnitTest {

    @Mock
    UserRepository userRepository;

    @InjectMocks
    UserServiceImpl userService;

    @Test
    void retrieveAllUsers_returnsUsersFromRepository() {
        List<User> fake = Arrays.asList(new User(), new User());
        when(userRepository.findAll()).thenReturn(fake);

        List<User> result = userService.retrieveAllUsers();

        assertNotNull(result);
        assertEquals(2, result.size());
    }

    @Test
    void addUser_savesAndReturnsUser() {
        User u = new User();
        when(userRepository.save(u)).thenReturn(u);

        User result = userService.addUser(u);

        assertNotNull(result);
        assertEquals(u, result);
    }
}
