require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

fecha_inicial = '2001-01-01'
fecha_final   = '2030-12-31'

MESTRES = {6  => {id: :id_tie_semestre, ds: :ds_tie_semestre, lk: :lk_tie_semestre},
           3  => {id: :id_tie_trimestre, ds: :ds_tie_trimestre, lk: :lk_tie_trimestre},
           1  => {id: :id_tie_mes, ds: :ds_tie_mes, lk: :lk_tie_mes}}

NOMESTRES = {12 => {id: :id_tie_anio, ds: :ds_tie_anio, lk: :lk_tie_anio},
             7  => {id: :id_tie_semana, ds: :ds_tie_semana, lk: :lk_tie_semana},
             0  => {id: :id_tie_dia, ds: :ds_tie_dia, lk: :lk_tie_dia}}

MESES = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio',
         'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']

ORDINALES = ['Primero', 'Segundo', 'Tercero', 'Cuarto', 'Quinto', 'Sexto']

def anio_bisiesto? año
  (año % 4 == 0 and not año % 100 == 0) or año % 400 == 0
end

def dia_del_anio año, mes, día
  días =
    case mes
    when 1  then 0
    when 2  then 31
    when 3  then 59
    when 4  then 90
    when 5  then 120
    when 6  then 151
    when 7  then 181
    when 8  then 212
    when 9  then 243
    when 10 then 273
    when 11 then 304
    when 12 then 334
    end + día

  if anio_bisiesto?(año) && mes > 2
    días + 1
  else
    días
  end
end

def dia_de_la_semana año, mes, día
  # 2001/1/1 fue lunes.
  días = 365 * (año - 2001) + (año - 2001) / 4 + dia_del_anio(año, mes, día)
  (días - 1) % 7 + 1
end

def dias_en_el_mes año, mes
  case mes
  when 1  then 31
  when 2
    anio_bisiesto?(año) ? 29 : 28
  when 3  then 31
  when 4  then 30
  when 5  then 31
  when 6  then 30
  when 7  then 31
  when 8  then 31
  when 9  then 30
  when 10 then 31
  when 11 then 30
  when 12 then 31
  end
end

def mestre meses_en_el_mestre, mes
  (mes - 1) / meses_en_el_mestre + 1
end

def semana_del_anio año, mes, día
  semana = (dia_del_anio(año, mes, día) - dia_de_la_semana(año, mes, día) + 10) / 7

  case semana
  when 0
    año -= 1
    semana = semana_del_anio(año, 12, 31)[1]
  when 53
    if (1..3).include? dia_de_la_semana(año, 12, 31)
      año += 1
      semana = 1
    end
  end

  [año, semana]
end

a_i, m_i, d_i = fecha_inicial.split('-').map(&:to_i)
a_f, m_f, d_f = fecha_final.split('-').map(&:to_i)

registros = Hash.new { |h,k| h[k] = [] }

a_i.upto(a_f) do |año|
  m_i_aux = año == a_i ? m_i : 1
  m_f_aux = año == a_f ? m_f : 12

  m_i_aux.upto(m_f_aux) do |mes|
    d_i_aux = (año == a_i && mes == m_i) ? d_i : 1
    d_f_aux = (año == a_f && mes == m_f) ? d_f : dias_en_el_mes(año, mes)
  
    registro = Hash.new
    registro[NOMESTRES[12][:id]] = año
    registros[12] << registro.dup if mes == 1

    MESTRES.each do |meses_en_el_mestre, campo_db|
      mestre = mestre(meses_en_el_mestre, mes)
      registro[campo_db[:id]] = 100 * año + mestre
      
      if meses_en_el_mestre == 1 || mes % meses_en_el_mestre == 1

        registro_aux = registro.dup

        registro_aux[campo_db[:ds]] =
          if meses_en_el_mestre == 1
            MESES[mestre - 1]
          else
            ORDINALES[mestre - 1]
          end
 
        registros[meses_en_el_mestre] << registro_aux
      end
    end

    d_i_aux.upto(d_f_aux) do |día|
      registro_semana = Hash.new

      año_semana, semana = semana_del_anio(año, mes, día)

      registro[NOMESTRES[7][:id]] =
      registro_semana[NOMESTRES[7][:id]] = 100 * año_semana + semana
      
      registro_semana[NOMESTRES[7][:ds]] = semana.to_s
      registro_semana[NOMESTRES[12][:id]] = año_semana

      registros[7] << registro_semana if
        !registros[7].last || 
          registros[7].last[NOMESTRES[7][:id]] != registro_semana[NOMESTRES[7][:id]]

      registro[NOMESTRES[0][:id]] = "#{año}-#{día}-#{mes}"
      registros[0] << registro.dup
    end
  end
end

# reg = registros[7].dup

# until reg.empty?
#   r1 = reg.pop
#   reg.each do |r2|
#     if r1[NOMESTRES[7][:id]] == r2[NOMESTRES[7][:id]]
#       puts r1
#       puts r2
#       puts ""
#     end
#   end
# end

registro = Hash.new
registro[NOMESTRES[12][:id]] = a_f + 1
registros[12] << registro
registro = Hash.new
registro[NOMESTRES[12][:id]] = a_i - 1
registros[12] << registro

# registros.delete(12)
# registros.delete(6)
# registros.delete(3)
# registros.delete(1)
# registros.delete(7)
TODOS = MESTRES.merge(NOMESTRES)
registros.each do |índice, registro|
  load registro, to: bases['panel'], table: TODOS[índice][:lk], append: false
end
