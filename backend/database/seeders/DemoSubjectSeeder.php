<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Center;
use App\Models\Subject;

class DemoSubjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Crear un centro educativo de prueba
        $center = Center::firstOrCreate(
            ['code' => 'DEMO-01'],
            [
                'name' => 'Instituto de Pruebas ClassNexus',
                'address' => 'Calle Falsa 123, Ciudadela Universitaria',
            ]
        );

        // 2. Crear asignaturas asociadas a este centro
        $subjects = [
            [
                'name' => 'Programación Orientada a Objetos',
                'description' => 'Módulo introductorio a la POO en Java y C# para Desarrollo de Aplicaciones.',
            ],
            [
                'name' => 'Bases de Datos Relacionales',
                'description' => 'Diseño y consulta de BBDD usando SQL estándar, PostgreSQL y optimización de consultas.',
            ],
            [
                'name' => 'Entornos de Desarrollo',
                'description' => 'Introducción a Git, metodologías ágiles, testing unitario y CI/CD.',
            ],
            [
                'name' => 'Diseño de Interfaces (UX/UI)',
                'description' => 'Desarrollo visual, prototipado en Figma y maquetación de componentes en Flutter.',
            ],
        ];

        foreach ($subjects as $subjectData) {
            Subject::firstOrCreate(
                ['name' => $subjectData['name'], 'center_id' => $center->id],
                $subjectData
            );
        }
    }
}
