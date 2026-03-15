function I=Scale(I)

I=I-nanmin(I(:));
I=I./nanmax(I(:));