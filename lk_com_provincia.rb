require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: 'provincias.csv', exclude: true do
  field 'id_com_provincia', map: 'id', type: Integer
  field 'ds_com_provincia', map: 'nombre'
end

datos =
transform datos do
  new_field 'cd_com_provincia', 'vacío'
  new_field 'id_com_pais', 32
end

load datos, to: bases['panel'], table: 'lk_com_provincia', append: false
