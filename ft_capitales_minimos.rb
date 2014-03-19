require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'
require 'pry'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

capitales =
extract from: bases['ecm'], table: 'vwResultadosECM', exclude: true do
  field 'id_com_compania', map: 'ciaid', type: Integer
  field 'anio'
  field 'trimestre'
  field 'Capital Minimo', type: Float, default: 0
  field 'Capital Computable', type: Float, default: 0
end

capitales =
transform capitales do
  new_field 'i_cap_imp_capital_minimo', capital_minimo >= 1 ?
    ((capital_computable - capital_minimo) / capital_minimo).to_i : 0

  del_field 'Capital Minimo'
  del_field 'Capital Computable'
  del_field 'anio'
  del_field 'trimestre'
  new_field 'id_tie_trimestre', (anio.to_s + '0' + trimestre.to_s).to_i
end

load capitales, to: bases['panel'], table: 'ft_capitales_minimos', append: false
