require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

ventas =
extract from: bases['infopro'], table: 'ProductoresDetalleNew', exclude: true do
  field 'id_com_compania', map: 'CiaID',
    type: Integer
  field 'id_tie_anio', map: 'Periodo',
    type: Integer
  field 'id_ven_canal', map: 'Tema'
  field 'id_ven_productor', map: 'NroCuit'
  field 'id_geo_provincia', map: 'Provincia',
    type: Integer
  field 'i_ven_imp_patrimoniales', map: 'MontPrESP'
  field 'i_ven_imp_personas', map: 'MontPrESPer'
end

canales = [
  {id_ven_canal: 'DIR', ds_ven_canal: 'Ventas directas'},
  {id_ven_canal: 'PAS', ds_ven_canal: 'Productores'},
  {id_ven_canal: 'ORG', ds_ven_canal: 'Organizadores'},
  {id_ven_canal: 'AGI', ds_ven_canal: 'Agentes institorios'},
  {id_ven_canal: 'SOC', ds_ven_canal: 'Sociedades de productores'}
]

load canales, to: bases['panel'], table: 'lk_ven_canal', append: false
load ventas, to: bases['panel'], table: 'ft_ventas', append: false
