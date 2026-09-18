esquema base de datos para operaciones mineras. Q-Answer
Motor: PostgreSQL

DROP TABLE IF EXISTS DetalleDespacho CASCADE;
DROP TABLE IF EXISTS Despacho CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;
DROP TABLE IF EXISTS ProductoFinal CASCADE;
DROP TABLE IF EXISTS Produccion CASCADE;
DROP TABLE IF EXISTS TipoMineral CASCADE;
DROP TABLE IF EXISTS Participacion_Proceso CASCADE;
DROP TABLE IF EXISTS ProcesoProductivo CASCADE;
DROP TABLE IF EXISTS Asignacion_Turno CASCADE;
DROP TABLE IF EXISTS Turno CASCADE;
DROP TABLE IF EXISTS Empleado CASCADE;
DROP TABLE IF EXISTS Rol CASCADE;
DROP TABLE IF EXISTS Mantenimiento CASCADE;
DROP TABLE IF EXISTS TipoMantenimiento CASCADE;
DROP TABLE IF EXISTS Equipo CASCADE;
DROP TABLE IF EXISTS Intendencia CASCADE;
DROP TABLE IF EXISTS GerenciaOperaciones CASCADE;


1. Estructura


CREATE TABLE GerenciaOperaciones(
    ID_Gerencia SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Tipo VARCHAR(50) NOT NULL CHECK (Tipo IN ('Mantenimiento', 'Integradas', 'Mina'))
);

CREATE TABLE Intendencia(
    ID_Intendencia SERIAL PRIMARY KEY,
    ID_Gerencia INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Tipo VARCHAR(50),
    CONSTRAINT fk_intendencia_gerencia FOREIGN KEY (ID_Gerencia)
        REFERENCES GerenciaOperaciones(ID_Gerencia) ON DELETE CASCADE
);

CREATE TABLE Equipo(
    ID_Equipo SERIAL PRIMARY KEY,
    ID_Intendencia INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Estado VARCHAR(50) DEFAULT 'Operativo',
    CONSTRAINT fk_equipo_intendencia FOREIGN KEY (ID_Intendencia)
        REFERENCES Intendencia(ID_Intendencia) ON DELETE CASCADE
);

2.- Mantenimiento

CREATE TABLE TipoMantenimiento(
    ID_TipoMantenimiento SERIAL PRIMARY KEY,
    Descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE Mantenimiento(
    ID_Mantenimiento SERIAL PRIMARY KEY,
    ID_TipoMantenimiento INT NOT NULL,
    ID_Equipo INT NOT NULL,
    Fecha DATE NOT NULL,
    Duracion INTERVAL,
    CONSTRAINT fk_mantenimiento_tipo FOREIGN KEY (ID_TipoMantenimiento)
        REFERENCES TipoMantenimiento(ID_TipoMantenimiento),
    CONSTRAINT fk_mantenimiento_equipo FOREIGN KEY (ID_Equipo)
        REFERENCES Equipo(ID_Equipo) ON DELETE CASCADE
);

3. Personal y turnos

CREATE TABLE Rol(
    ID_Rol SERIAL PRIMARY KEY,
    Nombre_Rol VARCHAR(100) NOT NULL
);

CREATE TABLE Empleado(
    ID_Empleado SERIAL PRIMARY KEY,
    ID_Intendencia INT NOT NULL,
    ID_Rol INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    CONSTRAINT fk_empleado_intendencia FOREIGN KEY (ID_Intendencia)
        REFERENCES Intendencia(ID_Intendencia),
    CONSTRAINT fk_empleado_rol FOREIGN KEY (ID_Rol)
        REFERENCES Rol(ID_Rol)
);

CREATE TABLE Turno(
    ID_Turno SERIAL PRIMARY KEY,
    Hora_Inicio TIME NOT NULL,
    Hora_Fin TIME NOT NULL,
    Duracion INTERVAL
);

CREATE TABLE Asignacion_Turno(
    ID_Turno INT NOT NULL,
    ID_Empleado INT NOT NULL,
    PRIMARY KEY (ID_Turno, ID_Empleado),
    CONSTRAINT fk_asignacion_turno FOREIGN KEY (ID_Turno)
        REFERENCES Turno(ID_Turno) ON DELETE CASCADE,
    CONSTRAINT fk_asignacion_empleado FOREIGN KEY (ID_Empleado)
        REFERENCES Empleado(ID_Empleado) ON DELETE CASCADE
);

4.- Producción y procesos

CREATE TABLE ProcesoProductivo(
    ID_Proceso SERIAL PRIMARY KEY,
    Fecha_Inicio DATE NOT NULL,
    Fecha_Fin DATE,
    Nombre VARCHAR(100) NOT NULL,
    Etapa VARCHAR(50)
);

CREATE TABLE Participacion_Proceso(
    ID_Empleado INT NOT NULL,
    ID_Proceso INT NOT NULL,
    Fecha_Inicio DATE NOT NULL,
    Fecha_Fin DATE,
    PRIMARY KEY (ID_Empleado, ID_Proceso),
    CONSTRAINT fk_participacion_empleado FOREIGN KEY (ID_Empleado)
        REFERENCES Empleado(ID_Empleado) ON DELETE CASCADE,
    CONSTRAINT fk_participacion_proceso FOREIGN KEY (ID_Proceso)
        REFERENCES ProcesoProductivo(ID_Proceso) ON DELETE CASCADE
);

CREATE TABLE TipoMineral(
    ID_TipoMineral SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Produccion(
    ID_Produccion SERIAL PRIMARY KEY,
    ID_Proceso INT NOT NULL,
    ID_TipoMineral INT,
    CONSTRAINT fk_produccion_proceso FOREIGN KEY (ID_Proceso)
        REFERENCES ProcesoProductivo(ID_Proceso) ON DELETE CASCADE,
    CONSTRAINT fk_produccion_tipomineral FOREIGN KEY (ID_TipoMineral)
        REFERENCES TipoMineral(ID_TipoMineral)
);

CREATE TABLE ProductoFinal(
    ID_Producto SERIAL PRIMARY KEY,
    ID_Produccion INT NOT NULL,
    Calidad_Pureza DECIMAL(5,2) CHECK (Calidad_Pureza BETWEEN 0 AND 100),
    ID_TipoMineral INT,
    Destino VARCHAR(100),
    CONSTRAINT fk_productofinal_produccion FOREIGN KEY (ID_Produccion)
        REFERENCES Produccion(ID_Produccion) ON DELETE CASCADE,
    CONSTRAINT fk_productofinal_tipomineral FOREIGN KEY (ID_TipoMineral)
        REFERENCES TipoMineral(ID_TipoMineral)
);

5.- Clientes y despacho

CREATE TABLE Cliente(
    ID_Cliente SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion_Facturacion VARCHAR(150)
);

CREATE TABLE Despacho(
    ID_Despacho SERIAL PRIMARY KEY,
    ID_Cliente INT NOT NULL,
    Fecha_Despacho DATE NOT NULL,
    CONSTRAINT fk_despacho_cliente FOREIGN KEY (ID_Cliente)
        REFERENCES Cliente(ID_Cliente)
);

CREATE TABLE DetalleDespacho(
    ID_Despacho INT NOT NULL,
    ID_Producto INT NOT NULL,
    Contrato VARCHAR(100),
    Fecha_Recibo DATE,
    PRIMARY KEY (ID_Despacho, ID_Producto),
    CONSTRAINT fk_detalledespacho_despacho FOREIGN KEY (ID_Despacho)
        REFERENCES Despacho(ID_Despacho) ON DELETE CASCADE,
    CONSTRAINT fk_detalledespacho_producto FOREIGN KEY (ID_Producto)
        REFERENCES ProductoFinal(ID_Producto)
);
