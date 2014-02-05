require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

monedas =
extract from: 'datos/monedas.csv' do
  field 'id_mon_moneda', map: 'código'
  field 'ds_mon_moneda', map: 'moneda', strip: true
end

monedas =
transform monedas do
  field 'ds_mon_moneda', (ds_mon_moneda.slice(0,1).capitalize + ds_mon_moneda.slice(1,ds_mon_moneda.length)).gsub('[', '(').gsub(']', ')')
end

load monedas, to: bases['panel'], table: 'lk_mon_moneda', append: false
