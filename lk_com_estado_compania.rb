require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Estados', exclude: true do
  field 'id_com_estado_compania', map: 'EstadoId', type: Integer
  field 'ds_com_estado_compania', map: 'Denominacion', strip: true
end

datos << {id_com_estado_compania: 0, ds_com_estado_compania: 'SIN REGISTRAR'}

datos =
transform datos do
  new_field 'cd_com_estado_compania', 'vacío'
end

load datos, to: bases['panel'], table: 'lk_com_estado_compania', append: false
