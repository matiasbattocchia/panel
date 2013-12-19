require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

lk_aud_auditor_actuario =
extract from: bases['auditores'], table: 'R_AuditoresActuarios', exclude: true do
  field 'id_aud_auditor_actuario', map: 'IdAud'
  field 'Nombres',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'Apellido',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ID_Nacionalidad', map: 'PaisNac'
  field 'id_aud_tipo', map: 'TipoProf'
  field 'id_aud_fecha_resolucion', map: 'Fech_Resol',
    reject_if: nil
  field 'id_aud_cuit', map: 'CUIT',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'id_aud_estado', map: 'estadoID'
end

nacionalidades =
extract from: bases['auditores'], table: 'ID_Nacionalidad' do
  field 'descripcion', strip: true
end

lk_aud_auditor_actuario =
transform lk_aud_auditor_actuario, join: nacionalidades, on: 'ID_Nacionalidad' do
  del_field 'ID_Nacionalidad'
  del_field 'descripcion'
  new_field 'ds_aud_pais', descripcion
end

estado =
{1 => 'Activo',
 2 => 'Sancionado',
 3 => 'Inhabilitado',
 4 => 'Solicitud cancelada',
 5 => 'Solicitud dada de baja',
 6 => 'Solicitud en trámite'}

lk_aud_auditor_actuario =
transform lk_aud_auditor_actuario do
  new_field 'ds_aud_auditor_actuario', nombres + ' ' + apellido
  del_field 'Nombres'
  del_field 'Apellido'
  new_field 'ds_aud_direccion', 'vacío'
  new_field 'cd_aud_auditor_actuario', 'vacío'
  new_field 'ds_aud_matricula', 'vacío'
  field 'id_aud_estado', estado[id_aud_estado]
  field 'id_aud_tipo', case id_aud_tipo
                       when 13 then 'Auditor'
                       when 15 then 'Actuario'
                       end
  field 'id_aud_fecha_resolucion', '2013-12-12'
end

load lk_aud_auditor_actuario, to: bases['panel'], table: 'lk_aud_auditor_actuario', append: false
