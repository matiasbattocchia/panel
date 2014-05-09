require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('bases_de_datos.yml')

companias =
extract(from: bases['panel'], table: 'LK_COM_COMPANIAS', exclude: true) do
  field 'id_com_compania'
  field 'id_com_reaseguradora', reject_if: 'Sí'
  field 'id_com_cierre_ejercicio', reject_unless: [6, 12]
end

entregas =
extract(from: bases['sinensup'], table: 'ENTREGAS', exclude: true) do
  field 'id_com_compania', map: 'ID_compania', type: Integer
  field 'id_cronograma', map: 'ID_cronograma'
  field 'id_balance', map: 'ID_ultima_entrega', reject_if: nil
end

entregas =
transform entregas, join: companias, on: 'id_com_compania' do
  del_field 'id_com_reaseguradora'
  del_field 'id_com_cierre_ejercicio'
end

cronogramas =
extract(from: bases['sinensup'], table: 'CRONOGRAMAS', exclude: true) do
  field 'id_tie_trimestre', map: 'periodo'
  field 'tipo_entrega', reject_unless: 'Trimestral'
  field 'id_cronograma', map: 'ID'
end

entregas =
transform entregas, join: cronogramas, on: 'id_cronograma' do
  del_field 'tipo_entrega'
  del_field 'id_cronograma'
end

balances =
extract from: bases['sinensup'], table: 'PLAN_CUENTAS_UNIFICADO', exclude: true do
  field 'id_balance', map: 'ID'
  field 'id_cue_version_rectificativo', map: 'version_rectificativo',
    type: Integer, default: 0
end

balances =
transform balances, join: entregas, on: 'id_balance' do
  field 'id_tie_trimestre'
  field 'id_com_compania'
  field 'id_balance'
  field 'id_cue_version_rectificativo'
end

balances.each do |balance|
  cuentas = extract(
    from: bases['sinensup'],
    table: 'CUENTAS',
    where: "ID_plan_de_cuentas_unificado = #{balance[:id_balance]}",
    exclude: true) do
      field 'id_bal_balance', map: 'ID_plan_de_cuentas_unificado'
      field 'codigo_id_sinensup', map: 'ID_codigo'
      field 'id_bal_subramo', map: 'ID_subramo', type: Integer
      field 'i_bal_imp_balance', map: 'importe', reject_if: 0
  end
end

# Esto es porque para una entrada dada en el balance de una compañía,
# esta puede señar el importe mediante una cantidad arbitraria de
# cuentas, siempre y cuando sumen el importe correspondiente.
# 
# Ejemplo: Entrega 4to trimestre de 2013, compañía AseguARTE,
# bajo el código "4.01.01.01.01.01.01.01" declara un importe de $10.000
# mediante 10.000 cuentas por valor de $1 cada una.
#
# Lo normal es que se declare una cuenta por importe
# en el balance, sin embargo lo dicho
# está permitido en Sinensup y es tenido en cuenta (valga la redundancia).
#
# aggregate() aplana datos.

cuentas =
aggregate cuentas do
  dim 'id_bal_balance'
  dim 'codigo_id_sinensup'
  dim 'id_bal_subramo'
  fact 'i_bal_imp_balance'
end

codigos_sinensup =
extract from: bases['sinensup'], table: 'CODIGOS', exclude: true do
  field 'codigo_id_sinensup', map: 'ID'
  field 'codigo_completo'
end

codigos_panel =
extract from: bases['panel'], table: 'lk_bal_nivel8', exclude: true do
  field 'id_bal_nivel8'
  field 'codigo_completo', map: 'cd_bal_nivel8_completo'
end

codigos =
transform codigos_sinensup, join: codigos_panel, on: 'codigo_completo'



cuentas =
transform cuentas, join: balances, on: 'id_bal_balance'

cuentas =
transform cuentas, join: codigos, on: 'codigo_id_sinensup' do
  del_field 'codigo_completo'
  del_field 'id_bal_balance'
  del_field 'codigo_id_sinensup'
  field     'id_tie_trimestre', id_tie_trimestre.gsub('-', '0').to_i
  new_field 'i_bal_signo', codigo_completo[0] == '4' ? -1 : 1
  new_field 'i_bal_saldo_anterior', 0
end

load cuentas, to: bases['panel'], table: 'ft_balance', append: false
