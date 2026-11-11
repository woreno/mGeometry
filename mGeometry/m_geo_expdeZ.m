function m = m_geo_expdeZ(z)
   zu = vunit(z);
   rv =  vunit(cross([0  0  1 ],zu));
%    m =  angleaxis2matrix(rv* acos( dot(zu,[0 0 1])  ));
   m =  angleaxis2matrix(rv*acos( zu(3) )  );

end