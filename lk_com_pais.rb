require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

países = Array.new

# países_ISO =
# extract from: 'country-list/country/cldr/es_AR/country.csv' do
#   field :iso
#   field :nombre, map: 'name'
# end

# países_UN =
# extract from: 'countries/countries.csv', separator: ';', exclude: true do
#   field :iso, map: 'cca2'
#   field :número, map: 'ccn3', type: Integer
# end

países =
transform países_ISO, join: países_UN, on: :iso

países << {número: 0, iso: 'vacío', nombre: 'SIN REGISTRAR'}

load países, to: bases['panel'], table: 'lk_com_pais', append: true do
  field :número, map: 'id_com_pais'
  field :iso, map: 'cd_com_pais'
  field :nombre, map: 'ds_com_pais'
end
