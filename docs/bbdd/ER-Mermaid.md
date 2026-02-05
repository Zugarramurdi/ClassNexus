erDiagram
  USER {
    uuid id PK
  }

  SUBJECT {
    uuid id PK
  }

  GROUP {
    uuid id PK
    uuid subject_id FK
  }

  ENROLMENT {
    uuid student_id PK, FK
    uuid group_id   PK, FK
  }

  TEACHING_ASSIGNMENT {
    uuid teacher_id PK, FK
    uuid group_id   PK, FK
  }

  MATERIAL {
    uuid id PK
    uuid group_id FK
    uuid teacher_id FK
  }

  ASSIGNMENT {
    uuid id PK
    uuid group_id FK
    uuid teacher_id FK
  }

  SUBMISSION {
    uuid id PK
    uuid assignment_id FK
    uuid student_id FK
  }

  GRADE {
    uuid submission_id PK, FK
    uuid teacher_id FK
  }

  SUBJECT ||--o{ GROUP : has
  USER ||--o{ ENROLMENT : student
  GROUP ||--o{ ENROLMENT : includes

  USER ||--o{ TEACHING_ASSIGNMENT : teacher
  GROUP ||--o{ TEACHING_ASSIGNMENT : taught_in

  GROUP ||--o{ MATERIAL : contains
  USER  ||--o{ MATERIAL : uploads

  GROUP ||--o{ ASSIGNMENT : has
  USER  ||--o{ ASSIGNMENT : creates

  ASSIGNMENT ||--o{ SUBMISSION : receives
  USER       ||--o{ SUBMISSION : submits

  SUBMISSION ||--o| GRADE : results_in
  USER       ||--o{ GRADE : grades
