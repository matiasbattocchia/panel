require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Actividad2', exclude: true do
  field :id_com_actividad2, map: 'ActId', type: Integer
  field :ds_com_actividad2, map: 'Denominacion', strip: true
end

datos << {id_com_actividad2: 0, ds_com_actividad2: 'SIN REGISTRAR'}

datos =
transform datos do
  new_field :cd_com_actividad2, 'vacío'
end

load datos, to: bases['panel'], table: 'lk_com_actividad2', append: false
