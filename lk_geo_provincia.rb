require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: 'datos/provincias.csv', exclude: true do
  field 'id_geo_provincia', map: 'id', type: Integer
  field 'ds_geo_provincia', map: 'nombre'
end

datos =
transform datos do
  new_field 'id_geo_pais', 'AR'
end

load datos, to: bases['panel'], table: 'lk_geo_provincia', append: false
