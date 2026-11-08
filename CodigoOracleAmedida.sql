-- 1. Registro del Esquema XML en la base de datos
BEGIN
  DBMS_XMLSCHEMA.registerSchema(
    SCHEMAURL => 'http://miservidor.com/departamento.xsd',
    SCHEMADOC => '<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="Departamento">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="nombre_depto" type="xs:string"/>
        <xs:element name="Empleados">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="Empleado" maxOccurs="unbounded">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="nombre" type="xs:string"/>
                    <xs:element name="apellido" type="xs:string"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
      <xs:attribute name="id" type="xs:integer" use="required"/>
    </xs:complexType>
  </xs:element>
</xs:schema>',
    LOCAL => TRUE,
    GENBEAN => FALSE,
    GENTYPES => FALSE,
    GENTABLES => FALSE
  );
END;
/

-- 2. Creación de la tabla validada contra el esquema
CREATE TABLE tabla_xml_deptos (
  id NUMBER,
  documento XMLTYPE
) XMLTYPE COLUMN documento 
  XMLSCHEMA "http://miservidor.com/departamento.xsd" 
  ELEMENT "Departamento";
/

-- 3. Inserción de un documento XML VÁLIDO (cumple con las reglas)
INSERT INTO tabla_xml_deptos VALUES (
  1, 
  XMLTYPE('<Departamento id="10"><nombre_depto>Administration</nombre_depto><Empleados><Empleado><nombre>Jennifer</nombre><apellido>Whalen</apellido></Empleado></Empleados></Departamento>')
);
/

-- 4. Intento de inserción de un documento XML INVÁLIDO (falta el atributo 'id') con validación estricta
DECLARE
  mi_xml XMLTYPE;
BEGIN
  mi_xml := XMLTYPE(
    '<Departamento><nombre_depto>Ventas</nombre_depto><Empleados><Empleado><nombre>Juan</nombre><apellido>Perez</apellido></Empleado></Empleados></Departamento>',
    'http://miservidor.com/departamento.xsd'
  );
  
  -- Forzamos la validación (Aquí es donde Oracle arroja el error ORA-31154 / LSX-00266)
  mi_xml.schemaValidate();
  
  INSERT INTO tabla_xml_deptos VALUES (3, mi_xml);
END;
/