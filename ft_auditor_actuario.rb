require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

ft_auditor_actuario =
extract from: bases['auditores'], table: 'CompaniasAudAct', exclude: true do
  field 'id_aud_auditor_actuario', map: 'IdAudAct',
    type: Integer
  field 'id_com_compania', map: 'IdCompania',
    type: Integer
end

ft_auditor_actuario = 
transform ft_auditor_actuario do
  new_field 'id_aud_fecha_desde', '2013-16-12'
  new_field 'id_aud_fecha_hasta', '2013-16-12'
  new_field 'id_aud_tipo_auditor', 'vacío'
  new_field 'id_aud_fecha_resolucion', '2013-16-12'
  new_field 'i_aud_cantidad', 1
end

load ft_auditor_actuario, to: bases['panel'], table: 'ft_auditor_actuario', append: false
