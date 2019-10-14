%%
%% Find edges in a single EPI E by directional filtering with
%% the filters provided in F. 
%% (See Algorithm 1: EPI Edge Detection in paper)
%%
function [c, z] = findEdgesEPI(E, F, gx, gy)

  % Directional filtering
  l = zeros( size(E, 1), size(E, 2), size(F, 3));
  a = zeros(size(l));
  b = zeros(size(l));
  for i = 1:size(F, 3)
    l(:, :, i) = abs(conv2(E(:, :, 1), F(:, :, i), 'same'));
    a(:, :, i) = abs(conv2(E(:, :, 2), F(:, :, i), 'same'));
    b(:, :, i) = abs(conv2(E(:, :, 3), F(:, :, i), 'same'));
  end

  % Select filter value with maximum response at each pixel
  [ml, mlIdx] = max(l, [], 3);
  [ma, maIdx] = max(a, [], 3);
  [mb, mbIdx] = max(b, [], 3);

  % Non-maximal suppression
  nl = nms(ml, [gx(mlIdx(:))' gy(mlIdx(:))']) .* ml;
  na = nms(ma, [gx(maIdx(:))' gy(maIdx(:))']) .* ma;
  nb = nms(mb, [gx(mbIdx(:))' gy(mbIdx(:))']) .* mb;

  % Standard-deviation based modulation
  vl = stdfilt( E(:, :, 1) ) .* nl;
  va = stdfilt( E(:, :, 2) ) .* na;
  vb = stdfilt( E(:, :, 3) ) .* nb;

  % Select as edge value the maximum across all channels...
  [c, cIdx] = max(cat(3, vl, va, vb), [], 3);

  % ... setting the corresponding pixel values in the slope map
  z = (cIdx == 1) .* mlIdx + (cIdx == 2) .* maIdx + (cIdx == 3) .* mbIdx;
end
