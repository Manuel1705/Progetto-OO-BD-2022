package Model;

import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;


public class Employee {
    private String ssn, firstName, lastName, phoneNum, email, address, role;
    LocalDate employmentDate;
    float salary;
    private Laboratory lab;
ArrayList<CareerDevelopment> careerChanges = new ArrayList<CareerDevelopment>();
    public Employee(String ssn, String firstName, String lastName, String phoneNum, String role, LocalDate employmentDate) {
        this.ssn = ssn;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phoneNum = phoneNum;
        this.employmentDate = employmentDate;
        this.role = role;
    }

    public Period getEmploymentTime() {
        return Period.between(employmentDate, LocalDate.now());
    }

    public void ChangeRole(String role, float salary) {
        if (role.equals("Junior") && getEmploymentTime().getYears() < 3 ||
                role.equals("Middle") && getEmploymentTime().getYears() >= 3 && getEmploymentTime().getYears() < 7 ||
                role.equals("Senior") && getEmploymentTime().getYears() >= 7 ||
                role.equals("Executive")){
            careerChanges.add(new CareerDevelopment(this.role, role, ssn, this.salary-salary));
            this.role = role;
            this.salary = salary;
        } else {
            System.out.println("Cambio ruolo non consentito");
        }
    }
    public String getRole(){
        return role;
    }
    public void assignLab(Laboratory lab){
        this.lab=lab;
    }
}
