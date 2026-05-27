clear; clc; close all;
% AM THANH 1: AM THANH GOC 
ten_file = 'giong_noi_cua_toi.wav'; 
try
    [tin_hieu_goc, Fs] = audioread(ten_file);
    if size(tin_hieu_goc, 2) > 1
        tin_hieu_goc = mean(tin_hieu_goc, 2); % Chuyen ve Mono neu la file Stereo
    end
    fprintf('Da nap thanh cong file goc: %s (Fs = %d Hz)\n', ten_file, Fs);
catch ME
    fprintf('Loi he thong: %s\n', ME.message);
    error('Hay chac chan ban da dat file "%s" vao dung folder dang mo cua MATLAB.', ten_file);
end
L = length(tin_hieu_goc);
t = (0:L-1)/Fs; 
am_thanh_1_goc = tin_hieu_goc; 

% AM THANH 2: MO PHONG TAI NGUOI GIA NGHE (HOI CHUNG PRESBYCUSIS)
N_order = 60;
f_cat_lowpass = 1200 / (Fs/2); 
b_tai = fir1(N_order, f_cat_lowpass, 'low');
am_thanh_tan_so_thap = filter(b_tai, 1, am_thanh_1_goc);
am_thanh_mo_phong = 0.9 * am_thanh_1_goc + 0.9 * am_thanh_tan_so_thap;
% 4. Nhân 0.3 để giảm âm lượng tổng thể xuống còn 30%
am_thanh_2_nguoi_gia = am_thanh_mo_phong * 0.3;
% AM THANH 3: XU LY TRO THINH THONG MINH DE NGUOI GIA NGHE DUOC RO RANG
f_cat = [1000, 5000] / (Fs/2); 
% Thiết kế bộ lọc thông dải bằng hàm fir1 
b_bandpass = fir1(N_order, f_cat, 'bandpass'); 
% Tách riêng phần âm thanh ở dải tần từ 1000Hz - 1400Hz
am_thanh_dai_boost = filter(b_bandpass, 1, am_thanh_1_goc);
% Trợ thính bằng cách giữ nguyên âm thanh gốc và cộng thêm phần dải tần được khuếch đại 
% (Khuếch đại thêm khoảng 19 lần để tổng biên độ vùng đó đạt xấp xỉ 20 lần)
am_thanh_3_qua_tro_thinh = (am_thanh_1_goc + am_thanh_dai_boost * 19) * 3.33;
% Chuẩn hóa biên độ (Giữ nguyên đoạn code cũ của bạn)
if max(abs(am_thanh_3_qua_tro_thinh)) > 1
    am_thanh_3_qua_tro_thinh = am_thanh_3_qua_tro_thinh / max(abs(am_thanh_3_qua_tro_thinh));
end
% DO THI TRUC QUAN CHUNG MINH 3 GIAI DOAN (MIEN THOI GIAN)
figure('Name', 'Do An Mo Phong Lao Thinh Presbycusis', 'Position', [100, 100, 1000, 700]);
subplot(3,1,1); plot(t, am_thanh_1_goc, 'b'); 
title('1. Am thanh GOC'); 
ylabel('Bien do'); grid on;
subplot(3,1,2); plot(t, am_thanh_2_nguoi_gia, 'r'); 
title('2. Am thanh NGUOI GIA NGHE '); 
ylabel('Bien do'); grid on;
subplot(3,1,3); plot(t, am_thanh_3_qua_tro_thinh, 'g'); 
title('3. Am thanh XU LY TRO THINH '); 
ylabel('Bien do'); xlabel('Thoi gian (s)'); grid on;
N_fft = 4096; % So diem FFT
F_axis = (0:N_fft/2-1) * (Fs / N_fft); % Truc tan so (Hz)
% Tinh pho bien do (chuyen sang thang do dB)
Spect_1 = 20*log10(abs(fft(am_thanh_1_goc, N_fft)));
Spect_2 = 20*log10(abs(fft(am_thanh_2_nguoi_gia, N_fft)));
Spect_3 = 20*log10(abs(fft(am_thanh_3_qua_tro_thinh, N_fft)));
figure('Name', 'Phan Tich Mien Tan So', 'Position', [150, 150, 800, 500]);
plot(F_axis, Spect_1(1:N_fft/2), 'b', 'LineWidth', 1.2); hold on;
plot(F_axis, Spect_2(1:N_fft/2), 'r', 'LineWidth', 1);
plot(F_axis, Spect_3(1:N_fft/2), 'g', 'LineWidth', 1);
title('Pho bien do cac tin hieu (Minh chung muc suy hao va bu dap)');
xlabel('Tan so (Hz)');
ylabel('Bien do (dB)');
legend('Am thanh goc', 'Nguoi gia nghe (Suy hao)', 'Sau tro thinh (Da bu dap)');
xlim([0 4000]); % Gioi han o 4000Hz de nhin ro vung cat 1000Hz-1400Hz
grid on;
% PHAT AM THANH SO SANH THEO THU TU (LAN LUOT 1 -> 2 -> 3)
thoi_gian_phat = L/Fs; 
fprintf('\n--- 1. DANG PHAT: AM THANH GOC ---\n');
sound(am_thanh_1_goc, Fs);
pause(thoi_gian_phat + 1); 
fprintf('--- 2. DANG PHAT: TAI NGUOI GIA NGHE  ---\n');
sound(am_thanh_2_nguoi_gia, Fs);
pause(thoi_gian_phat + 1); 
fprintf('--- 3. DANG PHAT: AM THANH QUA XU LY TRO THINH  ---\n');
sound(am_thanh_3_qua_tro_thinh, Fs);