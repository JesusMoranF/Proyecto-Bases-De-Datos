-- datos de prueba y test de logica (sp y triggers)
-- Motor: PostgreSQL

-- 1. Gerencias
INSERT INTO GerenciaOperaciones (Nombre, Tipo) VALUES
('Gerencia Mina Norte', 'Mina'),
('Gerencia Mantenimiento Central', 'Mantenimiento'),
('Gerencia Operaciones Integradas', 'Integradas');

-- 2. Intendencias
INSERT INTO Intendencia (ID_Gerencia, Nombre, Tipo) VALUES
(1, 'Intendencia de Extracción', 'Operativa'),
(2, 'Intendencia Flota Pesada', 'Técnica'),
(3, 'Intendencia Planta Concentradora', 'Procesamiento');

-- 3. Equipos
INSERT INTO Equipo (ID_Intendencia, Nombre, Estado) VALUES
(1, 'Pala Hidráulica CAT 6060', 'Operativo'),
(2, 'Camión Extracción Komatsu 930E', 'Operativo'),
(3, 'Chancador Primario Superior', 'Operativo');

-- 4. Tipos de Mantenimiento
INSERT INTO TipoMantenimiento (Descripcion) VALUES
('Preventivo 250 Horas'),
('Correctivo de Emergencia'),
('Predictivo Monitoreo de Aceite');

-- 5. Roles
INSERT INTO Rol (Nombre_Rol) VALUES
('Operador de Maquinaria Pesada'),
('Técnico Mecánico'),
('Ingeniero de Procesos'),
('Supervisor de Turno');

-- 6. Empleados
INSERT INTO Empleado (ID_Intendencia, ID_Rol, Nombre) VALUES
(1, 1, 'Carlos Mendoza'),
(2, 2, 'Ana María Rodríguez'),
(3, 3, 'Roberto Gómez'),
(1, 4, 'Sofía Valenzuela');

-- 7. Turnos (Dispara el trigger para cálculo de Duracion)
INSERT INTO Turno (Hora_Inicio, Hora_Fin) VALUES
('08:00:00', '16:00:00'),  -- Turno Diurno (Calcula 08:00:00)
('16:00:00', '00:00:00'),  -- Turno Tarde (Calcula 08:00:00)
('22:00:00', '06:00:00');  -- Turno Noche cruzando medianoche (Calcula 08:00:00)

-- 8. Asignaciones de Turno
INSERT INTO Asignacion_Turno (ID_Turno, ID_Empleado) VALUES
(1, 1),
(2, 2),
(3, 3);

-- 9. Procesos Productivos
INSERT INTO ProcesoProductivo (Fecha_Inicio, Fecha_Fin, Nombre, Etapa) VALUES
('2026-03-01', '2026-03-05', 'Chancado y Molienda Lote A', 'Molienda'),
('2026-03-06', NULL, 'Lixiviación en Pilas Lote B', 'Lixiviación');

-- 10. Participación en Procesos
INSERT INTO Participacion_Proceso (ID_Empleado, ID_Proceso, Fecha_Inicio) VALUES
(1, 1, '2026-03-01'),
(3, 2, '2026-03-06');

-- 11. Tipos de Minerales
INSERT INTO TipoMineral (Nombre) VALUES
('Cobre Sulfurado'),
('Cobre Oxidado'),
('Concentrado de Oro');

-- 12. Producción
INSERT INTO Produccion (ID_Proceso, ID_TipoMineral) VALUES
(1, 1),
(2, 2);

-- 13. Productos Finales
INSERT INTO ProductoFinal (ID_Produccion, Calidad_Pureza, ID_TipoMineral, Destino) VALUES
(1, 99.95, 1, 'Puerto de Antofagasta'),
(2, 85.50, 2, 'Refinería Central');

-- 14. Clientes
INSERT INTO Cliente (Nombre, Direccion_Facturacion) VALUES
('MetalCorp Trading International', 'Av. Las Condes 1234, Santiago, Chile'),
('Global Smelting Corp', 'Industrial Park Way 500, Texas, USA');

-- 15. Despachos
INSERT INTO Despacho (ID_Cliente, Fecha_Despacho) VALUES
(1, '2026-03-10'),
(2, '2026-03-12');

-- 16. Detalle de Despacho
INSERT INTO DetalleDespacho (ID_Despacho, ID_Producto, Contrato, Fecha_Recibo) VALUES
(1, 1, 'CT-2026-MIN-001', '2026-03-11'),
(2, 2, 'CT-2026-MIN-002', '2026-03-15');


-- Prueba del SP

-- Registrar mantenimiento en el equipo #2 (Camión Komatsu 930E) y actualizar su estado a "En mantenimiento"
CALL RegistrarMantenimiento(1, 2, '2026-03-16', '04:00:00'::INTERVAL);
