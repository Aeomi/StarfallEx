SF.Vectors = {}

--- Vector type
-- @shared
local vec_methods, vec_metamethods = SF.Typedef( "Vector" )
local wrap, unwrap = SF.CreateWrapper( vec_metamethods, true, false, debug.getregistry().Vector )

SF.DefaultEnvironment.Vector = function ( ... )
	return wrap( Vector( ... ) )
end

SF.Vectors.Wrap = wrap
SF.Vectors.Unwrap = unwrap
SF.Vectors.Methods = vec_methods
SF.Vectors.Metatable = vec_metamethods

local dgetmeta = debug.getmetatable

--- __newindex metamethod
function vec_metamethods.__newindex ( t, k, v )
	if type( k ) == "number" then
		if k >= 1 and k <= 3 then
			SF.UnwrapObject( t ).__newindex( SF.UnwrapObject( t ), k, v )
		end
	elseif k == "x" or k =="y" or k == "z" then
		SF.UnwrapObject( t ).__newindex( SF.UnwrapObject( t ), k, v )
	else
		rawset( t, k, v )
	end
end

local _p = vec_metamethods.__index
--- __index metamethod
function vec_metamethods.__index ( t, k )
	if type( k ) == "number" then
		if k >= 1 and k <= 3 then
			return unwrap( t )[ k ]
		end
	else
		if k == "x" or k =="y" or k == "z" then
			return unwrap( t )[ k ]
		end
	end
	return _p[ k ]
end

--- tostring metamethod
-- @return string representing the vector.
function vec_metamethods:__tostring ()
	return unwrap( self ):__tostring()
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled vector.
function vec_metamethods.__mul ( lhs, rhs )
	if dgetmeta( lhs ) == vec_metamethods then
		if dgetmeta( rhs ) == vec_metamethods then
			local a, b = unwrap( lhs ), unwrap( rhs )
			return wrap( Vector( a.x * b.x, a.y * b.y, a.z * b.z ) )
		end
		SF.CheckType( rhs, "number" )
		return wrap( unwrap( lhs ) * rhs )
	else
		if dgetmeta( lhs ) == vec_metamethods then
			local a, b = unwrap( lhs ), unwrap( rhs )
			return wrap( Vector( a.x * b.x, a.y * b.y, a.z * b.z ) )
		end
		SF.CheckType( lhs, "number" )
		return wrap( unwrap( rhs ) * lhs )
	end
end

--- division metamethod
-- @param n Scalar to divide the Vector by
-- @return Scaled vector.
function vec_metamethods:__div ( n )
	SF.CheckType( n, "number" )
	return SF.WrapObject( unwrap( self ):__div( n ) )
end

--- add metamethod
-- @param v Vector to add
-- @return Resultant vector after addition operation.
function vec_metamethods:__add ( v )
	SF.CheckType( v, vec_metamethods )
	return wrap( unwrap( self ):__add( unwrap( v ) ) )
end

--- sub metamethod
-- @param v Vector to subtract
-- @return Resultant vector after subtraction operation.
function vec_metamethods:__sub ( v )
	SF.CheckType( v, vec_metamethods )
	return wrap( unwrap( self ):__sub( unwrap( v ) ) )
end

--- unary minus metamethod
-- @return negated vector.
function vec_metamethods:__unm ()
	return wrap( unwrap( self ):__unm() )
end

--- equivalence metamethod
-- @return bool if both sides are equal.
function vec_metamethods:__eq ( ... )
	return SF.Sanitize( unwrap( self ):__eq( SF.Unsanitize( ... ) ) )
end

--- Add vector - Modifies self.
-- @param v Vector to add
-- @return nil
function vec_methods:add ( v )
	SF.CheckType( v, vec_metamethods )
	unwrap( self ):Add( unwrap( v ) )
end

--- Get the vector's angle.
-- @return Angle
function vec_methods:getAngle ()
	return SF.WrapObject( unwrap( self ):Angle() )
end

--- Returns the Angle between two vectors.
-- @param v Second Vector
-- @return Angle
function vec_methods:getAngleEx ( v )
	SF.CheckType( v, vec_metamethods )
	return SF.WrapObject( unwrap( self ):AngleEx( unwrap( v ) ) )
end

--- Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.
-- @param v Second Vector
-- @return Vector
function vec_methods:cross ( v )
	SF.CheckType( v, vec_metamethods )
	return wrap( unwrap( self ):Cross( unwrap( v ) ) )
end

--- Returns the pythagorean distance between the vector and the other vector.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistance ( v )
	SF.CheckType( v, vec_metamethods )
	return unwrap( self ):Distance( unwrap( v ) )
end

--- Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistanceSqr ( v )
	SF.CheckType( v, vec_metamethods )
	return unwrap( self ):DistToSqr( unwrap( v ) )
end

--- Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.
-- @param v Second Vector
-- @return Number
function vec_methods:dot ( v )
	SF.CheckType( v, vec_metamethods )
	return unwrap( self ):Dot( unwrap( v ) )
end

--- Returns a new vector with the same direction by length of 1.
-- @return Vector Normalised
function vec_methods:getNormalized ()
	return wrap( unwrap( self ):GetNormalized() )
end

--- Is this vector and v equal within tolerance t.
-- @param v Second Vector
-- @param t Tolerance number.
-- @return bool True/False.
function vec_methods:isEqualTol ( v, t )
	SF.CheckType( v, vec_metamethods )
	SF.CheckType( t, "number" )
	return unwrap( self ):IsEqualTol( unwrap( v ), t )
end

--- Are all fields zero.
-- @return bool True/False
function vec_methods:isZero ()
	return unwrap( self ):IsZero()
end

--- Get the vector's Length.
-- @return number Length.
function vec_methods:getLength ()
	return unwrap( self ):Length()
end

--- Get the vector's length squared ( Saves computation by skipping the square root ).
-- @return number length squared.
function vec_methods:getLengthSqr ()
	return unwrap( self ):LengthSqr()
end

--- Returns the length of the vector in two dimensions, without the Z axis.
-- @return number length
function vec_methods:getLength2D ()
	return unwrap( self ):Length2D()
end

--- Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )
-- @return number length squared.
function vec_methods:getLength2DSqr ()
	return unwrap( self ):Length2DSqr()
end

--- Scalar Multiplication of the vector. Self-Modifies.
-- @param n Scalar to multiply with.
-- @return nil
function vec_methods:mul ( n )
	SF.CheckType( n, "number" )
	unwrap( self ):Mul( n )
end

--- Set's all vector fields to 0.
-- @return nil
function vec_methods:setZero ()
	unwrap( self ):Zero()
end

--- Normalise the vector, same direction, length 0. Self-Modifies.
-- @return nil
function vec_methods:normalize ()
	unwrap( self ):Normalize()
end

--- Rotate the vector by Angle a. Self-Modifies.
-- @param a Angle to rotate by.
-- @return nil.
function vec_methods:rotate ( a )
	SF.CheckType( a, SF.Types[ "Angle" ] )
	unwrap( self ):Rotate( SF.UnwrapObject( a ) )
end

--- Return rotated vector by an axis
-- @param axis Axis the rotate around
-- @param degrees Angle to rotate by in degrees or nil if radians.
-- @param radians Angle to rotate by in radians or nil if degrees.
-- @return Rotated vector
function vec_methods:rotateAroundAxis(axis, degrees, radians)
	SF.CheckType( self, vec_metamethods )
	SF.CheckType( axis, vec_metamethods )
	if degrees then
		SF.CheckType( degrees, "number" )
		radians = math.rad(degrees)
	else
		SF.CheckType( radians, "number" )
	end
	local ca, sa = math.cos(radians), math.sin(radians)
	local x,y,z,x2,y2,z2 = axis.x, axis.y, axis.z, self.x, self.y, self.z
	local length = (x*x+y*y+z*z)^0.5
	x,y,z = x/length, y/length, z/length

	return wrap( Vector((ca + (x^2)*(1-ca)) * x2 + (x*y*(1-ca) - z*sa) * y2 + (x*z*(1-ca) + y*sa) * z2,
			(y*x*(1-ca) + z*sa) * x2 + (ca + (y^2)*(1-ca)) * y2 + (y*z*(1-ca) - x*sa) * z2,
			(z*x*(1-ca) - y*sa) * x2 + (z*y*(1-ca) + x*sa) * y2 + (ca + (z^2)*(1-ca)) * z2) )
end

--- Copies the values from the second vector to the first vector. Self-Modifies.
-- @param v Second Vector
-- @return nil
function vec_methods:set ( v )
	SF.CheckType( v, vec_metamethods )
	unwrap( self ):Set( unwrap( v ) )
end

--- Subtract v from this Vector. Self-Modifies.
-- @param v Second Vector.
-- @return nil
function vec_methods:sub ( v )
	SF.CheckType( v, vec_metamethods )
	unwrap( self ):Sub( unwrap( v ) )
end

--- Translates the vectors position into 2D user screen coordinates. Self-Modifies.
-- @return nil
function vec_methods:toScreen ()
	return unwrap( self ):ToScreen()
end

--- Returns whenever the given vector is in a box created by the 2 other vectors.
-- @param v1 Vector used to define AABox
-- @param v2 Second Vector to define AABox
-- @return bool True/False.
function vec_methods:withinAABox ( v1, v2 )
	SF.CheckType( v1, vec_metamethods )
	SF.CheckType( v2, vec_metamethods )
	return unwrap( self ):WithinAABox( unwrap( v1 ), unwrap( v2 ) )
end
