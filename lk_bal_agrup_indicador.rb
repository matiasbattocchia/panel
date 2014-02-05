require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

def extractor hash
  array = Array.new

  hash.each do |indicador, valor|
    if valor.class == Array
      valor.each do |codigo|
        array << {ds_bal_agrup_indicador: indicador, cd_bal_nivel8_completo: codigo}
      end
    elsif valor.class == Hash
      array = array + extractor(valor)
    end
  end

  array
end

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')
indicadores = extractor YAML.load_file('/home/matias/proyectos/panel/datos/indicadores.yml')

lk_bal_agrup_indicador =
transform indicadores, unique: 'ds_bal_agrup_indicador' do
  new_field 'id_bal_agrup_indicador', count
  del_field 'cd_bal_nivel8_completo'
end

codigos =
extract from: bases['panel'], table: 'lk_bal_nivel8', exclude: true do
  field 'id_bal_nivel8'
  field 'cd_bal_nivel8_completo'
end

rl_bal_cta_nivel8_indicador =
transform indicadores, join: codigos, on: 'cd_bal_nivel8_completo' do
  del_field 'cd_bal_nivel8_completo'
end

rl_bal_cta_nivel8_indicador =
transform rl_bal_cta_nivel8_indicador, join: lk_bal_agrup_indicador, on: 'ds_bal_agrup_indicador' do
  del_field 'ds_bal_agrup_indicador'
end

load lk_bal_agrup_indicador, to: bases['panel'], table: 'lk_bal_agrup_indicador', append: false
load rl_bal_cta_nivel8_indicador, to: bases['panel'], table: 'rl_bal_cta_nivel8_indicador', append: false
