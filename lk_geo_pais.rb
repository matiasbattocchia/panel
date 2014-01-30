require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

países_ISO =
extract from: 'datos/country-list/country/cldr/es_AR/country.csv' do
  field :iso
  field :nombre, map: 'name'
end

países_UN =
extract from: 'datos/countries/countries.csv', separator: ';', exclude: true do
  field :iso, map: 'cca2'
  field :número, map: 'ccn3', type: Integer
end

países =
transform países_ISO, join: países_UN, on: :iso

países << {número: 0, iso: 'NN', nombre: 'SIN REGISTRAR'}

load países, to: bases['panel'], table: 'lk_geo_pais', append: true do
  field :número, map: 'id_geo_numero_pais'
  field :iso, map: 'id_geo_pais'
  field :nombre, map: 'ds_geo_pais'
end
